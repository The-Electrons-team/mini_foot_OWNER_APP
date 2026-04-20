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

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );
      final res = await http.get(uri, headers: {'Accept-Language': 'fr'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _addressCtrl.text = data['display_name'] ?? '';
      }
    } catch (_) {}
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
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFF0EBE3)),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Center(
              child: GestureDetector(
                onTap: _ctrl.goBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EBE3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF1A1A1A),
                    size: 16,
                  ),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(
              _isEditing ? 'Modifier Terrain' : 'Nouveau Terrain',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF006F39),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildPhotosSection().animate().fadeIn(duration: 350.ms),
                const SizedBox(height: 20),
                _buildInfoSection().animate().fadeIn(duration: 350.ms, delay: 50.ms),
                const SizedBox(height: 20),
                _buildCapacitySection().animate().fadeIn(duration: 350.ms, delay: 100.ms),
                const SizedBox(height: 20),
                _buildEquipmentsSection().animate().fadeIn(duration: 350.ms, delay: 150.ms),
                const SizedBox(height: 20),
                _buildLocationSection().animate().fadeIn(duration: 350.ms, delay: 200.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Bouton Fixe en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFF0EBE3))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildSaveButton(),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Photos — Interface en pointillés ──────────────────────────────────
  Widget _buildPhotosSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: _pickImages,
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          dashPattern: const [6, 4],
          color: const Color(0xFF006F39).withAlpha(100),
          strokeWidth: 2,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(PhosphorIconsLight.cameraPlus,
                    color: Color(0xFF006F39), size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Ajouter des photos',
                  style: TextStyle(
                      color: Color(0xFF006F39),
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const Text(
                  'JPG, PNG (Max 5Mo)',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
      Obx(() => _images.isEmpty
          ? const SizedBox.shrink()
          : Container(
              height: 80,
              margin: const EdgeInsets.only(top: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4),
                itemCount: _images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF006F39)),
                        image: DecorationImage(
                          image: FileImage(File(_images[i].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _images.removeAt(i),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ]),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
    ],
  );

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      _images.addAll(images);
    }
  }

  // ── 2. Informations ──────────────────────────────────────────────────────
  Widget _buildInfoSection() => _Card(
    title: 'Informations',
    icon: PhosphorIconsLight.fileText,
    child: Column(
      children: [
        _Field(
          label: 'Nom du terrain',
          ctrl: _nameCtrl,
          hint: 'Ex: Terrain Synthétique A',
          icon: PhosphorIconsLight.pen,
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de surface',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 6),
            Obx(() => Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E0D8)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _surface.value,
                      isExpanded: true,
                      icon: const Icon(PhosphorIconsLight.caretDown,
                          color: Color(0xFF006F39), size: 16),
                      style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      items: _surfaces
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Row(children: [
                                  const Icon(PhosphorIconsLight.leaf,
                                      size: 16, color: Color(0xFF006F39)),
                                  const SizedBox(width: 8),
                                  Text(s),
                                ]),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _surface.value = v;
                      },
                    ),
                  ),
                )),
          ],
        ),
      ],
    ),
  );

  // ── 3. Formats de jeu — Chips ─────────────────────────────────────────────
  Widget _buildCapacitySection() => _Card(
    title: 'Formats de jeu',
    icon: PhosphorIconsLight.users,
    child: Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allCapacities.map((c) {
            final sel = _capacities.contains(c);
            return GestureDetector(
              onTap: () {
                if (sel) {
                  _capacities.remove(c);
                } else {
                  _capacities.add(c);
                }
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF006F39) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? const Color(0xFF006F39) : const Color(0xFFE5E0D8),
                  ),
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
  );

  // ── 4. Équipements — Grid ────────────────────────────────────────────────
  Widget _buildEquipmentsSection() => _Card(
    title: 'Équipements inclus',
    icon: PhosphorIconsLight.shieldCheck,
    child: Obx(() {
      final icons = {
        'Éclairage': PhosphorIconsLight.lightbulb,
        'Vestiaires': PhosphorIconsLight.shirtFolded,
        'Ballon': PhosphorIconsLight.soccerBall,
        'Caméra': PhosphorIconsLight.videoCamera,
        'Wifi': PhosphorIconsLight.wifiHigh,
        'Parking': PhosphorIconsLight.park,
        'Tribunes': PhosphorIconsLight.chair,
        'Buvette': PhosphorIconsLight.coffee,
        'Douches': PhosphorIconsLight.shower,
        'Arbitre': PhosphorIconsLight.flag,
      };
      
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.5,
        children: _equipments.entries.map((e) {
          final on = e.value;
          final icon = icons[e.key] ?? PhosphorIconsLight.checks;
          return GestureDetector(
            onTap: () => _equipments[e.key] = !on,
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: on ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: on ? const Color(0xFF006F39) : const Color(0xFFE5E0D8),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: on ? const Color(0xFF006F39) : const Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        color: on ? const Color(0xFF006F39) : const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }),
  );

  // ── 5. Localisation — Map et Recherche ────────────────────────────────────
  Widget _buildLocationSection() => _Card(
    title: 'Localisation',
    icon: PhosphorIconsLight.mapPin,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EBE3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E0D8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _searchAddress,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une adresse...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _useCurrentLocation,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF006F39),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(PhosphorIconsLight.gps, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),

        // Résultats de recherche Nominatim
        Obx(() {
          if (_searchResults.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E0D8)),
            ),
            child: Column(
              children: _searchResults.map((r) => ListTile(
                dense: true,
                leading: const Icon(PhosphorIconsLight.mapPin, size: 14),
                title: Text(r['display_name'] ?? '', style: const TextStyle(fontSize: 12)),
                onTap: () => _selectResult(r),
              )).toList(),
            ),
          );
        }),

        const SizedBox(height: 12),
        // Mini Map
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE3),
              border: Border.all(color: const Color(0xFFE5E0D8)),
            ),
            child: Stack(
              children: [
                Obx(() => FlutterMap(
                      mapController: _mapCtrl,
                      options: MapOptions(
                        initialCenter: _mapCenter.value,
                        initialZoom: 15,
                        onTap: (_, point) {
                          _mapCenter.value = point;
                          _reverseGeocode(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.minifoot.owner',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _mapCenter.value,
                              width: 80,
                              height: 80,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF006F39).withAlpha(50),
                                        shape: BoxShape.circle,
                                      ),
                                    ).animate(onPlay: (c) => c.repeat()).scale(
                                          begin: const Offset(1, 1),
                                          end: const Offset(2.5, 2.5),
                                          duration: 1500.ms,
                                          curve: Curves.easeOut,
                                        ).fadeOut(),
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF006F39),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'Glissez la carte pour affiner la position',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── 6. Bouton Enregistrer ────────────────────────────────────────────────
  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF006F39),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(PhosphorIconsLight.floppyDisk, size: 20),
          SizedBox(width: 10),
          Text(
            'Enregistrer le terrain',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
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

// ─── Widgets de structure ──────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Card({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E0D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E0D8)),
          ),
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

