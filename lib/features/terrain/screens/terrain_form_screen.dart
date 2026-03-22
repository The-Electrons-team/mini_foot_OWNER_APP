import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/lottie_success_dialog.dart';
import '../controllers/terrain_controller.dart';

const _kRadius = 16.0;
const _kCardPad = EdgeInsets.all(18.0);

class TerrainFormScreen extends StatefulWidget {
  const TerrainFormScreen({super.key});
  @override
  State<TerrainFormScreen> createState() => _TerrainFormScreenState();
}

class _TerrainFormScreenState extends State<TerrainFormScreen> {
  late final TerrainController _ctrl;
  late final bool _isEditing;

  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController();
  final _dimCtrl     = TextEditingController(text: '40 x 25 m');
  final _openCtrl    = TextEditingController(text: '08:00');
  final _closeCtrl   = TextEditingController(text: '23:00');
  final _searchCtrl  = TextEditingController();

  final _images      = <XFile>[].obs;
  final _surface     = 'Gazon synthétique'.obs;
  final _capacities  = <String>{}.obs; // multi-sélection
  final _mapCenter   = Rx<LatLng>(const LatLng(14.6937, -17.4441));
  final _mapCtrl     = MapController();
  final _searchResults = <Map<String, dynamic>>[].obs;
  final _isSearching   = false.obs;
  final _isLocating    = false.obs;

  final _equipments = <String, bool>{
    'Éclairage':  true,
    'Vestiaires': true,
    'Parking':    false,
    'Tribunes':   false,
    'Wi-Fi':      false,
    'Buvette':    false,
    'Douches':    false,
    'Arbitre':    false,
  }.obs;

  static const _surfaces = ['Gazon synthétique', 'Gazon naturel', 'Terre battue'];
  static const _allCapacities = ['5v5', '7v7', '11v11'];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<TerrainController>();
    _isEditing = _ctrl.selectedTerrain.value != null;
    final t = _ctrl.selectedTerrain.value;
    if (t != null) {
      _nameCtrl.text    = t.name;
      _addressCtrl.text = t.address;
      _descCtrl.text    = t.description ?? '';
      _priceCtrl.text   = '${t.price}';
      _surface.value    = t.surface;
      _capacities.add(t.capacity);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _addressCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _dimCtrl.dispose(); _openCtrl.dispose();
    _closeCtrl.dispose(); _searchCtrl.dispose();
    super.dispose();
  }

  // ── Recherche Nominatim ────────────────────────────────────────────────────
  Future<void> _searchAddress(String query) async {
    if (query.trim().length < 3) { _searchResults.clear(); return; }
    _isSearching.value = true;
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=sn',
      );
      final res = await http.get(uri, headers: {'Accept-Language': 'fr'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _searchResults.value = data.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    _isSearching.value = false;
  }

  void _selectResult(Map<String, dynamic> r) {
    final lat = double.tryParse(r['lat'] ?? '') ?? 14.6937;
    final lng = double.tryParse(r['lon'] ?? '') ?? -17.4441;
    final pt  = LatLng(lat, lng);
    _mapCenter.value = pt;
    _mapCtrl.move(pt, 15);
    _addressCtrl.text = r['display_name'] ?? '';
    _searchCtrl.clear();
    _searchResults.clear();
  }

  // ── Géolocalisation ────────────────────────────────────────────────────────
  Future<void> _useCurrentLocation() async {
    _isLocating.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS désactivé', 'Activez la localisation sur votre appareil',
            backgroundColor: kBgCard, colorText: kTextPrim);
        _isLocating.value = false;
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          Get.snackbar('Permission refusée', 'Autorisation de localisation requise',
              backgroundColor: kBgCard, colorText: kTextPrim);
          _isLocating.value = false;
          return;
        }
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      final pt = LatLng(pos.latitude, pos.longitude);
      _mapCenter.value = pt;
      _mapCtrl.move(pt, 16);
      // Reverse geocoding
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${pos.latitude}&lon=${pos.longitude}&format=json',
      );
      final res = await http.get(uri, headers: {'Accept-Language': 'fr'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _addressCtrl.text = data['display_name'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'obtenir la position',
          backgroundColor: kBgCard, colorText: kTextPrim);
    }
    _isLocating.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotosSection().animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 28),
            _buildInfoSection().animate().fadeIn(duration: 350.ms, delay: 60.ms),
            const SizedBox(height: 28),
            _buildSurfaceSection().animate().fadeIn(duration: 350.ms, delay: 100.ms),
            const SizedBox(height: 28),
            _buildCapacitySection().animate().fadeIn(duration: 350.ms, delay: 140.ms),
            const SizedBox(height: 28),
            _buildHoursSection().animate().fadeIn(duration: 350.ms, delay: 180.ms),
            const SizedBox(height: 28),
            _buildEquipmentsSection().animate().fadeIn(duration: 350.ms, delay: 220.ms),
            const SizedBox(height: 28),
            _buildLocationSection().animate().fadeIn(duration: 350.ms, delay: 260.ms),
            const SizedBox(height: 36),
            _buildSaveButton().animate().fadeIn(duration: 350.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: kBgCard,
    elevation: 0,
    centerTitle: true,
    leading: GestureDetector(
      onTap: _ctrl.goBack,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: kBgSurface, shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrim, size: 16),
      ),
    ),
    title: Text(
      _isEditing ? 'Modifier le terrain' : 'Nouveau terrain',
      style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14,
          fontWeight: FontWeight.w800, color: kGreen),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(height: 1, color: kDivider),
    ),
  );

  // ── 1. Photos ──────────────────────────────────────────────────────────────
  Widget _buildPhotosSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Photos du terrain',
          icon: PhosphorIcons.images(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      Obx(() {
        if (_images.isEmpty) {
          return GestureDetector(
            onTap: _pickImages,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(18),
              dashPattern: const [8, 4],
              color: kGreen.withValues(alpha: 0.5),
              strokeWidth: 2,
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  color: kGreenLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: kGreenLight,
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(PhosphorIcons.cameraPlus(PhosphorIconsStyle.duotone),
                          color: kGreen, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text('Ajouter des photos', style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: kGreen)),
                    const SizedBox(height: 4),
                    const Text('Plusieurs photos possibles',
                        style: TextStyle(fontSize: 11, color: kTextSub)),
                  ],
                ),
              ),
            ),
          );
        }
        return Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              SizedBox(height: 200, width: double.infinity,
                  child: Image.file(File(_images[0].path), fit: BoxFit.cover)),
              Positioned.fill(child: Container(
                decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                  stops: const [0.5, 1.0],
                )),
              )),
              Positioned(top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.photo_library_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text('${_images.length}', style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == _images.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: kBgCard, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kGreen.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.duotone),
                          color: kGreen, size: 22),
                    ),
                  );
                }
                return Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_images[i].path),
                        width: 72, height: 72, fit: BoxFit.cover)),
                  Positioned(top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => _images.removeAt(i),
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                            color: Colors.red.shade600, shape: BoxShape.circle),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ]);
      }),
    ],
  );

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) _images.addAll(picked);
  }

  // ── 2. Informations générales ──────────────────────────────────────────────
  Widget _buildInfoSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Informations générales',
          icon: PhosphorIcons.info(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      _Card(child: Column(children: [
        _Field(label: 'Nom du terrain', ctrl: _nameCtrl,
            hint: 'Ex: Terrain Alpha',
            icon: PhosphorIcons.courtBasketball(PhosphorIconsStyle.duotone)),
        const SizedBox(height: 14),
        _Field(label: 'Description', ctrl: _descCtrl,
            hint: 'Décrivez votre terrain, ses atouts...',
            icon: PhosphorIcons.textAlignLeft(PhosphorIconsStyle.duotone),
            maxLines: 3),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _Field(
            label: 'Prix / heure', ctrl: _priceCtrl, hint: '8000',
            icon: PhosphorIcons.currencyCircleDollar(PhosphorIconsStyle.duotone),
            keyboardType: TextInputType.number, suffix: 'F CFA',
          )),
          const SizedBox(width: 12),
          Expanded(child: _Field(
            label: 'Dimensions', ctrl: _dimCtrl, hint: '40 x 25 m',
            icon: PhosphorIcons.ruler(PhosphorIconsStyle.duotone),
          )),
        ]),
      ])),
    ],
  );

  // ── 3. Type de surface — DropdownButton stylisé ────────────────────────────
  Widget _buildSurfaceSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Type de surface',
          icon: PhosphorIcons.plant(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: kCardShadow,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _surface.value,
            isExpanded: true,
            dropdownColor: kBgCard,
            borderRadius: BorderRadius.circular(14),
            icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.duotone),
                color: kGreen, size: 18),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: kTextPrim),
            items: _surfaces.map((s) {
              final icons = {
                'Gazon synthétique': PhosphorIcons.plant(PhosphorIconsStyle.duotone),
                'Gazon naturel':     PhosphorIcons.tree(PhosphorIconsStyle.duotone),
                'Terre battue':      PhosphorIcons.mountains(PhosphorIconsStyle.duotone),
              };
              return DropdownMenuItem(
                value: s,
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: kGreenLight, borderRadius: BorderRadius.circular(8)),
                    child: Icon(icons[s]!, color: kGreen, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(s),
                ]),
              );
            }).toList(),
            onChanged: (v) { if (v != null) _surface.value = v; },
          ),
        ),
      )),
    ],
  );

  // ── 4. Format de jeu — multi-sélection ────────────────────────────────────
  Widget _buildCapacitySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Format(s) de jeu',
          icon: PhosphorIcons.users(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 6),
      const Text('Plusieurs formats possibles',
          style: TextStyle(fontSize: 11, color: kTextSub)),
      const SizedBox(height: 12),
      Obx(() => Row(
        children: _allCapacities.map((c) {
          final sel = _capacities.contains(c);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (sel) { _capacities.remove(c); }
                else { _capacities.add(c); }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                    right: c != _allCapacities.last ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? kGreen : kBgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel ? kGreen : kBorder, width: sel ? 2 : 1),
                  boxShadow: sel ? kCardShadow : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c, style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : kTextPrim,
                        fontFamily: 'Orbitron')),
                    const SizedBox(height: 4),
                    if (sel)
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white.withValues(alpha: 0.8), size: 14)
                    else
                      Icon(Icons.radio_button_unchecked_rounded,
                          color: kTextLight, size: 14),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    ],
  );

  // ── 5. Horaires ────────────────────────────────────────────────────────────
  Widget _buildHoursSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: "Horaires d'ouverture",
          icon: PhosphorIcons.clock(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      _Card(child: Row(children: [
        Expanded(child: _Field(label: 'Ouverture', ctrl: _openCtrl, hint: '08:00',
            icon: PhosphorIcons.sun(PhosphorIconsStyle.duotone))),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 12, right: 12),
          child: Container(width: 20, height: 2, color: kTextLight),
        ),
        Expanded(child: _Field(label: 'Fermeture', ctrl: _closeCtrl, hint: '23:00',
            icon: PhosphorIcons.moon(PhosphorIconsStyle.duotone))),
      ])),
    ],
  );

  // ── 6. Équipements ─────────────────────────────────────────────────────────
  Widget _buildEquipmentsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Équipements',
          icon: PhosphorIcons.wrench(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      Obx(() {
        final icons = {
          'Éclairage':  PhosphorIcons.lightbulb(PhosphorIconsStyle.duotone),
          'Vestiaires': PhosphorIcons.tShirt(PhosphorIconsStyle.duotone),
          'Parking':    PhosphorIcons.car(PhosphorIconsStyle.duotone),
          'Tribunes':   PhosphorIcons.armchair(PhosphorIconsStyle.duotone),
          'Wi-Fi':      PhosphorIcons.wifiHigh(PhosphorIconsStyle.duotone),
          'Buvette':    PhosphorIcons.coffee(PhosphorIconsStyle.duotone),
          'Douches':    PhosphorIcons.shower(PhosphorIconsStyle.duotone),
          'Arbitre':    PhosphorIcons.flag(PhosphorIconsStyle.duotone),
        };
        return GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 3.0,
          children: _equipments.entries.map((e) {
            final on = e.value;
            return GestureDetector(
              onTap: () => _equipments[e.key] = !on,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: on ? kGreenLight : kBgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: on ? kGreen : kBorder),
                ),
                child: Row(children: [
                  Icon(icons[e.key]!, color: on ? kGreen : kTextLight, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.key, style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: on ? kGreen : kTextSub),
                      overflow: TextOverflow.ellipsis)),
                  if (on)
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        color: kGreen, size: 14),
                ]),
              ),
            );
          }).toList(),
        );
      }),
    ],
  );

  // ── 7. Localisation ────────────────────────────────────────────────────────
  Widget _buildLocationSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionTitle(label: 'Localisation',
          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.duotone)),
      const SizedBox(height: 12),
      _Card(child: Column(children: [
        // Barre de recherche
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rechercher une adresse', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: kTextSub)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 14, color: kTextPrim),
                  onChanged: _searchAddress,
                  decoration: InputDecoration(
                    hintText: 'Ex: Keur Gorgui, Dakar',
                    hintStyle: const TextStyle(fontSize: 13, color: kTextLight),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone),
                          color: kGreen, size: 18),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44),
                    filled: true, fillColor: kBgSurface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kGreen, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Bouton position actuelle
              Obx(() => GestureDetector(
                onTap: _isLocating.value ? null : _useCurrentLocation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: kGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: kCardShadow,
                  ),
                  child: _isLocating.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Icon(PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                          color: Colors.white, size: 22),
                ),
              )),
            ]),
          ],
        ),

        // Résultats de recherche
        Obx(() {
          if (_isSearching.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: kGreen, strokeWidth: 2)),
            );
          }
          if (_searchResults.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: _searchResults.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final name = (r['display_name'] as String?) ?? '';
                return InkWell(
                  onTap: () => _selectResult(r),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: i < _searchResults.length - 1
                          ? const Border(bottom: BorderSide(color: kDivider))
                          : null,
                    ),
                    child: Row(children: [
                      Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                          color: kGreen, size: 16),
                      const SizedBox(width: 10),
                      Expanded(child: Text(name,
                          style: const TextStyle(fontSize: 12, color: kTextPrim),
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 14),

        // Champ adresse (rempli auto ou manuel)
        _Field(label: 'Adresse complète', ctrl: _addressCtrl,
            hint: 'Ex: Cité Keur Gorgui, Dakar',
            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.duotone)),

        const SizedBox(height: 16),

        // Carte interactive
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 240,
            child: Obx(() => FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: _mapCenter.value,
                initialZoom: 14,
                onTap: (_, point) {
                  _mapCenter.value = point;
                  // Reverse geocoding au tap
                  _reverseGeocode(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=${dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? ''}',
                  userAgentPackageName: 'com.electrons.mini_foot_owner_flutter',
                  tileSize: 512, zoomOffset: -1,
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: _mapCenter.value,
                    width: 50, height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kGreen, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [BoxShadow(
                            color: kGreen.withValues(alpha: 0.4),
                            blurRadius: 12, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.sports_soccer_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ]),
              ],
            )),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: kTextLight),
          const SizedBox(width: 6),
          const Text('Appuyez sur la carte pour placer le marqueur',
              style: TextStyle(fontSize: 11, color: kTextSub)),
        ]),
      ])),
    ],
  );

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );
      final res = await http.get(uri, headers: {'Accept-Language': 'fr'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['display_name'] != null) {
          _addressCtrl.text = data['display_name'];
        }
      }
    } catch (_) {}
  }

  // ── Bouton enregistrer ─────────────────────────────────────────────────────
  Widget _buildSaveButton() => SizedBox(
    width: double.infinity, height: 56,
    child: ElevatedButton.icon(
      onPressed: _onSave,
      icon: Icon(
        _isEditing
            ? PhosphorIcons.check(PhosphorIconsStyle.duotone)
            : PhosphorIcons.plus(PhosphorIconsStyle.duotone),
        color: Colors.white, size: 22,
      ),
      label: Text(
        _isEditing ? 'Enregistrer les modifications' : 'Créer le terrain',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen, foregroundColor: Colors.white,
        elevation: 4, shadowColor: kGreen.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );

  void _onSave() {
    Get.dialog(
      LottieSuccessDialog(
        message: _isEditing ? 'Terrain modifié !' : 'Terrain créé !',
        subtitle: _isEditing
            ? 'Les modifications ont été enregistrées'
            : 'Votre nouveau terrain est prêt',
      ),
      barrierDismissible: false,
    );
    Future.delayed(const Duration(seconds: 2), _ctrl.goBack);
  }
}

// ─── Widgets privés ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionTitle({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 34, height: 34,
      decoration: BoxDecoration(color: kGreenLight,
          borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: kGreen, size: 18),
    ),
    const SizedBox(width: 10),
    Text(label, style: const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w800, color: kTextPrim)),
  ]);
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: _kCardPad,
    decoration: BoxDecoration(
      color: kBgCard, borderRadius: BorderRadius.circular(_kRadius),
      border: Border.all(color: kBorder), boxShadow: kCardShadow,
    ),
    child: child,
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? suffix;

  const _Field({
    required this.label, required this.ctrl, required this.hint,
    required this.icon, this.maxLines = 1,
    this.keyboardType = TextInputType.text, this.suffix,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: kTextSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: kTextPrim),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: kTextLight),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: kGreen, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontSize: 12, color: kTextSub,
              fontWeight: FontWeight.w600),
          filled: true, fillColor: kBgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kGreen, width: 1.5)),
        ),
      ),
    ],
  );
}
