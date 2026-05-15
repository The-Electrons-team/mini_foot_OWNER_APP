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
import '../controllers/owner_zone_options.dart';
import '../controllers/terrain_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class TerrainFormScreen extends StatefulWidget {
  const TerrainFormScreen({super.key});
  @override
  State<TerrainFormScreen> createState() => _TerrainFormScreenState();
}

class _SubTerrainDraft {
  final String? divisionGroup;
  final TextEditingController nameCtrl;
  final TextEditingController capacityCtrl;
  final TextEditingController priceCtrl;
  final RxString type;
  final RxString surface;
  final RxBool isActive;
  final RxBool allowFull;
  final RxBool allowHalf;
  final RxBool allowThird;

  _SubTerrainDraft({
    this.divisionGroup,
    required String name,
    int capacity = 10,
    String type = '5v5',
    String surface = 'Gazon synthétique',
    int? pricePerHour,
    bool isActive = true,
    bool allowFull = true,
    bool allowHalf = false,
    bool allowThird = false,
  }) : nameCtrl = TextEditingController(text: name),
       capacityCtrl = TextEditingController(text: '$capacity'),
       priceCtrl = TextEditingController(
         text: pricePerHour == null ? '' : '$pricePerHour',
       ),
       type = type.obs,
       surface = surface.obs,
       isActive = isActive.obs,
       allowFull = allowFull.obs,
       allowHalf = allowHalf.obs,
       allowThird = allowThird.obs;

  factory _SubTerrainDraft.fromModels(List<SubTerrainModel> models) {
    final first = models.first;
    final physicalName = first.physicalName ?? _stripDivisionLabel(first.name);
    SubTerrainModel? full;
    for (final model in models) {
      if (model.divisionType == 'FULL') {
        full = model;
        break;
      }
    }
    final half = models.any((m) => m.divisionType == 'HALF');
    final third = models.any((m) => m.divisionType == 'THIRD');
    return _SubTerrainDraft(
      divisionGroup: first.divisionGroup ?? first.id,
      name: physicalName,
      capacity: first.capacity,
      type: first.type,
      surface: first.surface ?? 'Gazon synthétique',
      pricePerHour: full?.pricePerHour ?? first.pricePerHour,
      isActive: models.any((m) => m.isActive),
      allowFull: full != null || (!half && !third),
      allowHalf: half,
      allowThird: third,
    );
  }

  List<SubTerrainModel>? toModels(int index) {
    final name = nameCtrl.text.trim();
    final capacity = int.tryParse(capacityCtrl.text.trim());
    final priceText = priceCtrl.text.trim();
    final customPrice = priceText.isEmpty ? null : int.tryParse(priceText);
    if (name.isEmpty || capacity == null || capacity <= 0) return null;
    if (!allowFull.value && !allowHalf.value && !allowThird.value) return null;
    final group =
        divisionGroup ??
        'terrain_${index + 1}_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';

    SubTerrainModel unit(
      String label,
      String divisionType,
      int divisionIndex,
      int? price,
    ) {
      return SubTerrainModel(
        name: '$name - $label',
        physicalName: name,
        divisionGroup: group,
        divisionType: divisionType,
        divisionIndex: divisionIndex,
        capacity: capacity,
        type: type.value,
        surface: surface.value,
        pricePerHour: price,
        isActive: isActive.value,
      );
    }

    final units = <SubTerrainModel>[];
    if (allowFull.value) units.add(unit('Entier', 'FULL', 0, customPrice));
    if (allowHalf.value) {
      final price = customPrice == null ? null : (customPrice / 2).ceil();
      units
        ..add(unit('Demi 1', 'HALF', 1, price))
        ..add(unit('Demi 2', 'HALF', 2, price));
    }
    if (allowThird.value) {
      final price = customPrice == null ? null : (customPrice / 3).ceil();
      units
        ..add(unit('Tiers 1', 'THIRD', 1, price))
        ..add(unit('Tiers 2', 'THIRD', 2, price))
        ..add(unit('Tiers 3', 'THIRD', 3, price));
    }
    return units;
  }

  void dispose() {
    nameCtrl.dispose();
    capacityCtrl.dispose();
    priceCtrl.dispose();
  }
}

String _stripDivisionLabel(String value) {
  return value
      .replaceAll(RegExp(r'\s*-\s*(Entier|Demi\s+\d+|Tiers\s+\d+)$'), '')
      .trim();
}

class _TerrainFormScreenState extends State<TerrainFormScreen> {
  late final TerrainController _ctrl;
  late final bool _isEditing;

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _dimCtrl = TextEditingController(text: '40 x 25 m');
  final _openCtrl = TextEditingController(text: '08:00');
  final _closeCtrl = TextEditingController(text: '23:00');
  final _searchCtrl = TextEditingController();

  final _images = <XFile>[].obs;
  final _surface = 'Gazon synthétique'.obs;
  final _zone = 'DAKAR'.obs;
  final _capacities = <String>{}.obs;
  final _mapCenter = Rx<LatLng>(const LatLng(14.6937, -17.4441));
  final _mapCtrl = MapController();
  final _searchResults = <Map<String, dynamic>>[].obs;
  final _isSearching = false.obs;
  final _isLocating = false.obs;
  final _isSaving = false.obs;
  final _miniTerrains = <_SubTerrainDraft>[].obs;

  final _equipments = <String, bool>{
    'Éclairage': true,
    'Vestiaires': true,
    'Parking': false,
    'Tribunes': false,
    'Wi-Fi': false,
    'Buvette': false,
    'Douches': false,
    'Arbitre': false,
  }.obs;

  static const _surfaces = [
    'Gazon synthétique',
    'Gazon naturel',
    'Terre battue',
  ];
  static const _allCapacities = ['5v5', '7v7', '11v11'];
  static const _miniTerrainTypes = ['5v5', '7v7', '9v9', '11v11'];

  String get _mapboxToken => dotenv.env['MAPBOX_ACCESS_TOKEN']?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<TerrainController>();
    _isEditing = _ctrl.selectedTerrain.value != null;
    final t = _ctrl.selectedTerrain.value;
    if (t != null) {
      _nameCtrl.text = t.name;
      _addressCtrl.text = t.address;
      _descCtrl.text = t.description ?? '';
      _priceCtrl.text = '${t.pricePerHour}';
      _zone.value = t.zone;

      const validSurfaces = [
        'Gazon synthétique',
        'Gazon naturel',
        'Terre battue',
      ];
      final surf = t.features.firstWhere(
        (f) => validSurfaces.contains(f),
        orElse: () => 'Gazon synthétique',
      );
      _surface.value = surf;

      const caps = {'5v5', '7v7', '11v11'};
      for (final f in t.features) {
        if (caps.contains(f)) _capacities.add(f);
        if (_equipments.containsKey(f)) _equipments[f] = true;
      }

      if (t.lat != null && t.lng != null) {
        _mapCenter.value = LatLng(t.lat!, t.lng!);
      }

      final grouped = <String, List<SubTerrainModel>>{};
      for (final subTerrain in t.subTerrains) {
        final key =
            subTerrain.divisionGroup ??
            subTerrain.physicalName ??
            subTerrain.id ??
            subTerrain.name;
        grouped.putIfAbsent(key, () => []).add(subTerrain);
      }
      _miniTerrains.value = grouped.values
          .where((group) => group.isNotEmpty)
          .map(_SubTerrainDraft.fromModels)
          .toList();
    }

    if (_miniTerrains.isEmpty) {
      _miniTerrains.add(
        _SubTerrainDraft(name: 'Terrain A', capacity: 10, type: '5v5'),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _dimCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _searchCtrl.dispose();
    for (final miniTerrain in _miniTerrains) {
      miniTerrain.dispose();
    }
    super.dispose();
  }

  // ── Recherche Nominatim ────────────────────────────────────────────────────
  Future<void> _searchAddress(String query) async {
    if (query.trim().length < 3) {
      _searchResults.clear();
      return;
    }
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
    final pt = LatLng(lat, lng);
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
        Get.snackbar(
          'GPS désactivé',
          'Activez la localisation sur votre appareil',
          backgroundColor: kBgCard,
          colorText: kTextPrim,
        );
        await Geolocator.openLocationSettings();
        _isLocating.value = false;
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          Get.snackbar(
            'Permission refusée',
            'Autorisation de localisation requise',
            backgroundColor: kBgCard,
            colorText: kTextPrim,
          );
          _isLocating.value = false;
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission bloquée',
          'Activez la localisation dans les réglages',
          backgroundColor: kBgCard,
          colorText: kTextPrim,
        );
        await Geolocator.openAppSettings();
        _isLocating.value = false;
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final pt = LatLng(pos.latitude, pos.longitude);
      _mapCenter.value = pt;
      _mapCtrl.move(pt, 16);
      _addressCtrl.text = 'Votre position';
      _searchCtrl.text = 'Votre position';
      _searchResults.clear();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'obtenir la position',
        backgroundColor: kBgCard,
        colorText: kTextPrim,
      );
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
            border: Border(bottom: BorderSide(color: Color(0xFFF0EBE3))),
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
              _isEditing ? 'Modifier Parcelle' : 'Nouvelle Parcelle',
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
                _buildInfoSection().animate().fadeIn(
                  duration: 350.ms,
                  delay: 50.ms,
                ),
                const SizedBox(height: 20),
                _buildMiniTerrainsSection().animate().fadeIn(
                  duration: 350.ms,
                  delay: 100.ms,
                ),
                const SizedBox(height: 20),
                _buildCapacitySection().animate().fadeIn(
                  duration: 350.ms,
                  delay: 150.ms,
                ),
                const SizedBox(height: 20),
                _buildEquipmentsSection().animate().fadeIn(
                  duration: 350.ms,
                  delay: 200.ms,
                ),
                const SizedBox(height: 20),
                _buildLocationSection().animate().fadeIn(
                  duration: 350.ms,
                  delay: 250.ms,
                ),
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

  // ── 1. Photos ──────────────────────────────────────────────────────────────
  Widget _buildPhotosSection() {
    final existingImage = _ctrl.selectedTerrain.value?.displayImage ?? '';

    return Obx(() {
      final hasLocalImage = _images.isNotEmpty;
      final hasExistingImage = existingImage.isNotEmpty;
      final hasPreview = hasLocalImage || hasExistingImage;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E0D8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    PhosphorIconsLight.imageSquare,
                    color: Color(0xFF006F39),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Photos du terrain',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _IconPillButton(
                  icon: PhosphorIconsLight.plus,
                  label: hasPreview ? 'Ajouter' : 'Choisir',
                  onTap: _pickImages,
                ),
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickImages,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasLocalImage)
                        Image.file(File(_images.first.path), fit: BoxFit.cover)
                      else if (hasExistingImage)
                        Image.network(
                          existingImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _PhotoEmptyState(onTap: _pickImages),
                        )
                      else
                        _PhotoEmptyState(onTap: _pickImages),
                      if (hasPreview) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.42),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Photo principale',
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006F39),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  PhosphorIconsLight.cameraPlus,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(bottom: 2),
                  itemCount: _images.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      return _AddPhotoTile(onTap: _pickImages);
                    }

                    return _PhotoThumb(
                      file: File(_images[index].path),
                      isPrimary: index == 0,
                      onRemove: () => _images.removeAt(index),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

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
          label: 'Nom de la parcelle *',
          ctrl: _nameCtrl,
          hint: 'Ex: Complexe Foot Almadies',
          icon: PhosphorIconsLight.pen,
        ),
        const SizedBox(height: 16),
        // Zone
        _buildDropdown(
          label: 'Zone *',
          obs: _zone,
          items: ownerZoneLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Prix
        _Field(
          label: 'Prix par heure (XOF) *',
          ctrl: _priceCtrl,
          hint: 'Prix par défaut, ex: 15000',
          icon: PhosphorIconsLight.currencyDollar,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // Description
        _MultilineField(
          label: 'Description',
          ctrl: _descCtrl,
          hint: 'Décrivez la parcelle et ses espaces…',
        ),
        const SizedBox(height: 16),
        // Surface
        _buildDropdown(
          label: 'Type de surface',
          obs: _surface,
          items: _surfaces
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      const Icon(
                        PhosphorIconsLight.leaf,
                        size: 16,
                        color: Color(0xFF006F39),
                      ),
                      const SizedBox(width: 8),
                      Text(s),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );

  Widget _buildDropdown({
    required String label,
    required RxString obs,
    required List<DropdownMenuItem<String>> items,
  }) => Column(
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
      Obx(
        () => Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E0D8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: obs.value,
              isExpanded: true,
              icon: const Icon(
                PhosphorIconsLight.caretDown,
                color: Color(0xFF006F39),
                size: 16,
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: items,
              onChanged: (v) {
                if (v != null) obs.value = v;
              },
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildMiniTerrainsSection() => _Card(
    title: 'Terrains du complexe',
    icon: PhosphorIconsLight.soccerBall,
    trailing: _IconPillButton(
      icon: PhosphorIconsLight.plus,
      label: 'Ajouter',
      onTap: _addMiniTerrain,
    ),
    child: Obx(
      () => Column(
        children: [
          ...List.generate(_miniTerrains.length, (index) {
            final miniTerrain = _miniTerrains[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _miniTerrains.length - 1 ? 0 : 12,
              ),
              child: _buildMiniTerrainCard(miniTerrain, index),
            );
          }),
        ],
      ),
    ),
  );

  Widget _buildMiniTerrainCard(_SubTerrainDraft miniTerrain, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E0D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  PhosphorIconsLight.soccerBall,
                  color: Color(0xFF006F39),
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Terrain ${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Obx(
                () => Switch.adaptive(
                  value: miniTerrain.isActive.value,
                  activeThumbColor: const Color(0xFF006F39),
                  onChanged: (value) => miniTerrain.isActive.value = value,
                ),
              ),
              if (_miniTerrains.length > 1)
                IconButton(
                  onPressed: () => _removeMiniTerrain(miniTerrain),
                  icon: const Icon(
                    PhosphorIconsLight.trash,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Nom du terrain *',
            ctrl: miniTerrain.nameCtrl,
            hint: 'Ex: Terrain A',
            icon: PhosphorIconsLight.pen,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Format',
                  obs: miniTerrain.type,
                  items: _miniTerrainTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: 'Capacité',
                  ctrl: miniTerrain.capacityCtrl,
                  hint: '10',
                  icon: PhosphorIconsLight.users,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Surface',
                  obs: miniTerrain.surface,
                  items: _surfaces
                      .map(
                        (surface) => DropdownMenuItem(
                          value: surface,
                          child: Text(surface),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: 'Prix perso',
                  ctrl: miniTerrain.priceCtrl,
                  hint: 'Prix entier',
                  icon: PhosphorIconsLight.currencyDollar,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Options réservables',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DivisionChip(
                  label: 'Entier',
                  selected: miniTerrain.allowFull.value,
                  onTap: () => miniTerrain.allowFull.value =
                      !miniTerrain.allowFull.value,
                ),
                _DivisionChip(
                  label: 'Demi',
                  selected: miniTerrain.allowHalf.value,
                  onTap: () => miniTerrain.allowHalf.value =
                      !miniTerrain.allowHalf.value,
                ),
                _DivisionChip(
                  label: 'Tiers',
                  selected: miniTerrain.allowThird.value,
                  onTap: () => miniTerrain.allowThird.value =
                      !miniTerrain.allowThird.value,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addMiniTerrain() {
    final name = String.fromCharCode(65 + _miniTerrains.length);
    _miniTerrains.add(
      _SubTerrainDraft(name: 'Terrain $name', capacity: 10, type: '5v5'),
    );
  }

  void _removeMiniTerrain(_SubTerrainDraft miniTerrain) {
    miniTerrain.dispose();
    _miniTerrains.remove(miniTerrain);
  }

  // ── 3. Formats de jeu — Chips ─────────────────────────────────────────────
  Widget _buildCapacitySection() => _Card(
    title: 'Formats disponibles',
    icon: PhosphorIconsLight.users,
    child: Obx(
      () => Wrap(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF006F39) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? const Color(0xFF006F39)
                      : const Color(0xFFE5E0D8),
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
      ),
    ),
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
                  Icon(
                    icon,
                    color: on
                        ? const Color(0xFF006F39)
                        : const Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        color: on
                            ? const Color(0xFF006F39)
                            : const Color(0xFF6B7280),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une adresse...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
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
            Obx(
              () => GestureDetector(
                onTap: _isLocating.value ? null : _useCurrentLocation,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006F39),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLocating.value
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          PhosphorIconsLight.gps,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
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
              children: _searchResults
                  .map(
                    (r) => ListTile(
                      dense: true,
                      leading: const Icon(PhosphorIconsLight.mapPin, size: 14),
                      title: Text(
                        r['display_name'] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _selectResult(r),
                    ),
                  )
                  .toList(),
            ),
          );
        }),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _addressCtrl,
          builder: (context, value, child) {
            final address = value.text.trim();
            if (address.isEmpty) return const SizedBox.shrink();

            return Obx(
              () => Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCDE8D4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006F39),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        PhosphorIconsLight.mapPin,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_mapCenter.value.latitude.toStringAsFixed(5)}, ${_mapCenter.value.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(
                              color: Color(0xFF006F39),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

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
                Obx(
                  () => FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _mapCenter.value,
                      initialZoom: 15,
                      onTap: (_, point) {
                        _mapCenter.value = point;
                        _reverseGeocode(point);
                      },
                      onPositionChanged: (camera, hasGesture) {
                        if (hasGesture) _mapCenter.value = camera.center;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _mapboxToken.isEmpty
                            ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                            : 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxToken',
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
                                          color: const Color(
                                            0xFF006F39,
                                          ).withAlpha(50),
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                      .animate(onPlay: (c) => c.repeat())
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(2.5, 2.5),
                                        duration: 1500.ms,
                                        curve: Curves.easeOut,
                                      )
                                      .fadeOut(),
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006F39),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2.5,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
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
                  ),
                ),
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Text(
                        'Glissez la carte pour affiner la position',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                        ),
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
  Widget _buildSaveButton() => Obx(
    () => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving.value ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006F39),
          disabledBackgroundColor: const Color(0xFF006F39).withAlpha(120),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(PhosphorIconsLight.floppyDisk, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Enregistrer la parcelle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );

  Future<void> _onSave() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez saisir un nom de complexe',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final price = int.tryParse(_priceCtrl.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar(
        'Champ requis',
        'Veuillez saisir un prix valide (en XOF)',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final subTerrainGroups = <List<SubTerrainModel>>[];
    for (var i = 0; i < _miniTerrains.length; i++) {
      final models = _miniTerrains[i].toModels(i);
      if (models == null) {
        subTerrainGroups.clear();
        break;
      }
      subTerrainGroups.add(models);
    }
    final subTerrains = subTerrainGroups.expand((models) => models).toList();
    if (subTerrains.isEmpty ||
        subTerrainGroups.length != _miniTerrains.length) {
      Get.snackbar(
        'Terrain incomplet',
        'Chaque terrain doit avoir un nom, une capacité valide et au moins une option réservable',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez sélectionner une adresse sur la carte',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    _isSaving.value = true;
    try {
      final features = [
        _surface.value,
        ..._capacities,
        ..._equipments.entries.where((e) => e.value).map((e) => e.key),
      ];

      final authCtrl = Get.find<AuthController>();

      await _ctrl.saveTerrain(
        name: name,
        address: address,
        zone: _zone.value,
        pricePerHour: price,
        lat: _mapCenter.value.latitude,
        lng: _mapCenter.value.longitude,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        features: features,
        subTerrains: subTerrains,
        images: _images.map((x) => File(x.path)).toList(),
        managerId: authCtrl.user.value?.id,
      );

      Get.dialog(
        LottieSuccessDialog(
          message: _isEditing ? 'Terrain modifié !' : 'Terrain créé !',
          subtitle: _isEditing
              ? 'Les modifications ont été enregistrées'
              : 'Votre complexe et ses terrains sont prêts',
        ),
        barrierDismissible: false,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        _ctrl.goBack();
      });
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      Get.snackbar('Erreur', message, snackPosition: SnackPosition.TOP);
    } finally {
      _isSaving.value = false;
    }
  }
}

// ─── Widgets de structure ──────────────────────────────────────────────────

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF006F39),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoEmptyState extends StatelessWidget {
  final VoidCallback onTap;

  const _PhotoEmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        dashPattern: const [7, 5],
        color: const Color(0xFF006F39).withAlpha(110),
        strokeWidth: 1.5,
        child: Container(
          width: double.infinity,
          color: const Color(0xFFE8F5E9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    PhosphorIconsLight.cameraPlus,
                    color: Color(0xFF006F39),
                    size: 25,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ajouter une photo',
                  style: TextStyle(
                    color: Color(0xFF006F39),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'JPG ou PNG',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E0D8)),
        ),
        child: const Icon(
          PhosphorIconsLight.plus,
          color: Color(0xFF006F39),
          size: 22,
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final File file;
  final bool isPrimary;
  final VoidCallback onRemove;

  const _PhotoThumb({
    required this.file,
    required this.isPrimary,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFF006F39)
                  : const Color(0xFFE5E0D8),
              width: isPrimary ? 2 : 1,
            ),
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -7,
          right: -7,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
        if (isPrimary)
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF006F39),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _Card({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

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
              const Spacer(),
              ?trailing,
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
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.keyboardType,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E0D8)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: const Color(0xFF006F39), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _DivisionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DivisionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006F39) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF006F39) : const Color(0xFFE5E0D8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;

  const _MultilineField({
    required this.label,
    required this.ctrl,
    required this.hint,
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
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E0D8)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}
