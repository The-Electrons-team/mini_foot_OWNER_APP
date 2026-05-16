import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _PricingPeriodDraft {
  final TextEditingController labelCtrl;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;
  final TextEditingController priceCtrl;
  final RxSet<int> days;

  _PricingPeriodDraft({
    required String label,
    required String startTime,
    required String endTime,
    required int pricePerHour,
    List<int> days = const [],
  }) : labelCtrl = TextEditingController(text: label),
       startCtrl = TextEditingController(text: startTime),
       endCtrl = TextEditingController(text: endTime),
       priceCtrl = TextEditingController(text: '$pricePerHour'),
       days = days.toSet().obs;

  factory _PricingPeriodDraft.fromModel(PricingPeriodModel model) {
    return _PricingPeriodDraft(
      label: model.label,
      startTime: model.startTime,
      endTime: model.endTime,
      pricePerHour: model.pricePerHour,
      days: model.days,
    );
  }

  PricingPeriodModel? toModel({double ratio = 1}) {
    final label = labelCtrl.text.trim();
    final start = startCtrl.text.trim();
    final end = endCtrl.text.trim();
    final price = int.tryParse(priceCtrl.text.trim());
    if (label.isEmpty || price == null || price <= 0) return null;
    if (!_isValidTime(start) || !_isValidTime(end)) return null;
    if (_timeToMinutes(end) <= _timeToMinutes(start)) return null;
    return PricingPeriodModel(
      label: label,
      startTime: start,
      endTime: end,
      pricePerHour: (price * ratio).ceil(),
      days: days.toList()..sort(),
    );
  }

  void dispose() {
    labelCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    priceCtrl.dispose();
  }
}

class _SubTerrainDraft {
  final String? divisionGroup;
  final Map<String, String> idsByDivision;
  final TextEditingController nameCtrl;
  final TextEditingController capacityCtrl;
  final TextEditingController priceCtrl;
  final RxSet<String> formats;
  final RxString surface;
  final RxBool isActive;
  final RxBool allowFull;
  final RxBool allowHalf;
  final RxBool allowThird;
  final RxList<_PricingPeriodDraft> pricingPeriods;

  _SubTerrainDraft({
    this.divisionGroup,
    Map<String, String>? idsByDivision,
    required String name,
    int capacity = 10,
    String type = '5v5',
    String surface = 'Gazon synthétique',
    int? pricePerHour,
    bool isActive = true,
    bool allowFull = true,
    bool allowHalf = false,
    bool allowThird = false,
    List<PricingPeriodModel> pricingPeriods = const [],
  }) : idsByDivision = idsByDivision ?? const {},
       nameCtrl = TextEditingController(text: name),
       capacityCtrl = TextEditingController(text: '$capacity'),
       priceCtrl = TextEditingController(
         text: pricePerHour == null ? '' : '$pricePerHour',
       ),
       formats = type
           .split(',')
           .map((value) => value.trim())
           .where((value) => value.isNotEmpty)
           .toSet()
           .obs,
       surface = surface.obs,
       isActive = isActive.obs,
       allowFull = allowFull.obs,
       allowHalf = allowHalf.obs,
       allowThird = allowThird.obs,
       pricingPeriods = pricingPeriods
           .map(_PricingPeriodDraft.fromModel)
           .toList()
           .obs;

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
    SubTerrainModel? halfModel;
    SubTerrainModel? thirdModel;
    for (final model in models) {
      if (model.divisionType == 'HALF') halfModel ??= model;
      if (model.divisionType == 'THIRD') thirdModel ??= model;
    }
    final half = models.any((m) => m.divisionType == 'HALF');
    final third = models.any((m) => m.divisionType == 'THIRD');
    int? inferredFullPrice = full?.pricePerHour;
    if (inferredFullPrice == null && halfModel?.pricePerHour != null) {
      inferredFullPrice = halfModel!.pricePerHour! * 2;
    }
    if (inferredFullPrice == null && thirdModel?.pricePerHour != null) {
      inferredFullPrice = thirdModel!.pricePerHour! * 3;
    }
    inferredFullPrice ??= first.pricePerHour;
    final idsByDivision = <String, String>{};
    for (final model in models) {
      if (model.id == null || model.id!.isEmpty) continue;
      idsByDivision['${model.divisionType}:${model.divisionIndex}'] =
          model.id!;
    }
    return _SubTerrainDraft(
      divisionGroup: first.divisionGroup ?? first.id,
      idsByDivision: idsByDivision,
      name: physicalName,
      capacity: first.capacity,
      type: first.type,
      surface: first.surface ?? 'Gazon synthétique',
      pricePerHour: inferredFullPrice,
      pricingPeriods: full?.pricingPeriods ?? first.pricingPeriods,
      isActive: models.any((m) => m.isActive),
      allowFull: full != null || (!half && !third),
      allowHalf: half,
      allowThird: third,
    );
  }

  List<SubTerrainModel>? toModels(int index, int defaultPricePerHour) {
    final name = nameCtrl.text.trim();
    final capacity = int.tryParse(capacityCtrl.text.trim());
    final selectedFormats = _TerrainFormScreenState._miniTerrainTypes
        .where(formats.contains)
        .toList();
    final priceText = priceCtrl.text.trim();
    final customPrice = priceText.isEmpty ? null : int.tryParse(priceText);
    if (name.isEmpty || capacity == null || capacity <= 0) return null;
    if (selectedFormats.isEmpty) return null;
    if (customPrice != null && customPrice <= 0) return null;
    if (!allowFull.value && !allowHalf.value && !allowThird.value) return null;
    if (pricingPeriods.any((period) => period.toModel() == null)) return null;
    final group =
        divisionGroup ??
        'terrain_${index + 1}_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';

    List<PricingPeriodModel> scaledPricingPeriods(double ratio) {
      return pricingPeriods
          .map((period) => period.toModel(ratio: ratio))
          .whereType<PricingPeriodModel>()
          .toList();
    }

    SubTerrainModel unit(
      String label,
      String divisionType,
      int divisionIndex,
      int? price,
      double priceRatio,
    ) {
      return SubTerrainModel(
        id: idsByDivision['$divisionType:$divisionIndex'],
        name: '$name - $label',
        physicalName: name,
        divisionGroup: group,
        divisionType: divisionType,
        divisionIndex: divisionIndex,
        capacity: capacity,
        type: selectedFormats.join(', '),
        surface: surface.value,
        pricePerHour: price,
        pricingPeriods: scaledPricingPeriods(priceRatio),
        isActive: isActive.value,
      );
    }

    final units = <SubTerrainModel>[];
    if (allowFull.value) units.add(unit('Entier', 'FULL', 0, customPrice, 1));
    if (allowHalf.value) {
      final price = ((customPrice ?? defaultPricePerHour) / 2).ceil();
      units
        ..add(unit('Demi 1', 'HALF', 1, price, 0.5))
        ..add(unit('Demi 2', 'HALF', 2, price, 0.5));
    }
    if (allowThird.value) {
      final price = ((customPrice ?? defaultPricePerHour) / 3).ceil();
      units
        ..add(unit('Tiers 1', 'THIRD', 1, price, 1 / 3))
        ..add(unit('Tiers 2', 'THIRD', 2, price, 1 / 3))
        ..add(unit('Tiers 3', 'THIRD', 3, price, 1 / 3));
    }
    return units;
  }

  void addPricingPeriod() {
    pricingPeriods.add(
      _PricingPeriodDraft(
        label: 'Soirée',
        startTime: '18:00',
        endTime: '23:00',
        pricePerHour: int.tryParse(priceCtrl.text.trim()) ?? 0,
      ),
    );
  }

  void removePricingPeriod(_PricingPeriodDraft period) {
    period.dispose();
    pricingPeriods.remove(period);
  }

  void dispose() {
    nameCtrl.dispose();
    capacityCtrl.dispose();
    priceCtrl.dispose();
    for (final period in pricingPeriods) {
      period.dispose();
    }
  }
}

bool _isValidTime(String value) => RegExp(r'^\d{2}:\d{2}$').hasMatch(value);

int _timeToMinutes(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return -1;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
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
  final _priceCtrl = TextEditingController(text: '10000');
  final _dimCtrl = TextEditingController(text: '40 x 25 m');
  final _openCtrl = TextEditingController(text: '08:00');
  final _closeCtrl = TextEditingController(text: '23:00');

  final _images = <XFile>[].obs;
  final _surface = 'Gazon synthétique'.obs;
  final _zone = 'DAKAR'.obs;
  final _capacities = <String>{}.obs;
  final _mapCenter = Rx<LatLng>(const LatLng(14.6937, -17.4441));
  final _isLocating = false.obs;
  final _isSaving = false.obs;
  final _step = 0.obs;
  final _editingTerrainIndex = RxnInt();
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
    'Ballon': false,
  }.obs;

  static const _surfaces = [
    'Gazon synthétique',
    'Gazon naturel',
    'Terre battue',
  ];
  static const _allCapacities = ['5v5', '7v7', '11v11'];
  static const _miniTerrainTypes = ['5v5', '7v7', '9v9', '11v11'];
  static const _dayLabels = {
    1: 'Lun',
    2: 'Mar',
    3: 'Mer',
    4: 'Jeu',
    5: 'Ven',
    6: 'Sam',
    0: 'Dim',
  };

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

    if (_miniTerrains.isNotEmpty) _editingTerrainIndex.value = 0;
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
    for (final miniTerrain in _miniTerrains) {
      miniTerrain.dispose();
    }
    super.dispose();
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
      await _reverseGeocode(pt);
      if (_addressCtrl.text.trim().isEmpty) {
        _addressCtrl.text = 'Position actuelle détectée';
      }
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
              _isEditing ? 'Modifier complexe' : 'Nouveau complexe',
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
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 108),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: 220.ms,
                    child: KeyedSubtree(
                      key: ValueKey(_step.value),
                      child: _buildCurrentStep(),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFF0EBE3)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: _buildBottomBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    final current = _step.value + 1;
    final titles = [
      'Infos',
      'Photos',
      'Terrains',
      'Terrain',
      'Résumé',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Étape $current sur 5',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final active = index <= _step.value;
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF006F39)
                      : const Color(0xFFE5E0D8),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          titles[_step.value],
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_step.value) {
      case 0:
        return Column(
          children: [
            _buildInfoSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildPhotosSection(),
            const SizedBox(height: 16),
            _buildEquipmentsSection(),
          ],
        );
      case 2:
        return _buildTerrainListStep();
      case 3:
        return _buildTerrainEditorStep();
      default:
        return _buildReviewStep();
    }
  }

  Widget _buildTerrainListStep() {
    return _Card(
      title: 'Terrains du complexe',
      icon: PhosphorIconsLight.soccerBall,
      trailing: _IconPillButton(
        icon: PhosphorIconsLight.plus,
        label: 'Ajouter',
        onTap: _addMiniTerrain,
      ),
      child: Obx(() {
        if (_miniTerrains.isEmpty) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E0D8)),
                ),
                child: const Text(
                  'Aucun terrain ajouté pour le moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addMiniTerrain,
                  icon: const Icon(PhosphorIconsLight.plus, size: 18),
                  label: const Text('Ajouter un terrain'),
                ),
              ),
            ],
          );
        }

        return Column(
          children: List.generate(_miniTerrains.length, (index) {
            final terrain = _miniTerrains[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _miniTerrains.length - 1 ? 0 : 10,
              ),
              child: _TerrainDraftTile(
                index: index,
                terrain: terrain,
                onEdit: () {
                  _editingTerrainIndex.value = index;
                  _step.value = 3;
                },
                onDelete: _miniTerrains.length <= 1
                    ? null
                    : () => _removeMiniTerrain(terrain),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildTerrainEditorStep() {
    return Obx(() {
      if (_miniTerrains.isEmpty) {
        return _Card(
          title: 'Terrain',
          icon: PhosphorIconsLight.soccerBall,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addMiniTerrain,
              icon: const Icon(PhosphorIconsLight.plus, size: 18),
              label: const Text('Ajouter un terrain'),
            ),
          ),
        );
      }

      final index = (_editingTerrainIndex.value ?? 0)
          .clamp(
        0,
        _miniTerrains.length - 1,
      )
          .toInt();
      final terrain = _miniTerrains[index];
      return _buildMiniTerrainCard(terrain, index);
    });
  }

  Widget _buildReviewStep() {
    final equipments = _equipments.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    return Column(
      children: [
        _Card(
          title: 'Complexe',
          icon: PhosphorIconsLight.buildings,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewLine(label: 'Nom', value: _nameCtrl.text.trim()),
              _ReviewLine(label: 'Zone', value: ownerZoneLabels[_zone.value] ?? _zone.value),
              _ReviewLine(label: 'Adresse', value: _addressCtrl.text.trim()),
              _ReviewLine(label: 'Photos', value: '${_images.length} ajoutée(s)'),
              _ReviewLine(
                label: 'Équipements',
                value: equipments.isEmpty ? 'Aucun' : equipments.join(', '),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Card(
          title: 'Terrains',
          icon: PhosphorIconsLight.soccerBall,
          child: Obx(
            () => Column(
              children: List.generate(_miniTerrains.length, (index) {
                final terrain = _miniTerrains[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _miniTerrains.length - 1 ? 0 : 10,
                  ),
                  child: _TerrainDraftTile(
                    index: index,
                    terrain: terrain,
                    onEdit: () {
                      _editingTerrainIndex.value = index;
                      _step.value = 3;
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ],
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
                    'Photos du complexe',
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
    title: 'Complexe',
    icon: PhosphorIconsLight.fileText,
    child: Column(
      children: [
        _Field(
          label: 'Nom du complexe *',
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
        // Description
        _MultilineField(
          label: 'Description',
          ctrl: _descCtrl,
          hint: 'Décrivez le complexe et ses terrains...',
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
    title: 'Terrains physiques',
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
            label: 'Nom du terrain physique *',
            ctrl: miniTerrain.nameCtrl,
            hint: 'Ex: Terrain A',
            icon: PhosphorIconsLight.pen,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormatsSelector(miniTerrain),
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
                  hint: 'Prix 1h entier',
                  icon: PhosphorIconsLight.currencyDollar,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Découpes réservables',
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
                  label: 'Full',
                  selected: miniTerrain.allowFull.value,
                  onTap: () => miniTerrain.allowFull.value =
                      !miniTerrain.allowFull.value,
                ),
                _DivisionChip(
                  label: 'Moitié',
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
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tarifs par période',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _IconPillButton(
                label: 'Ajouter',
                icon: PhosphorIconsLight.plus,
                onTap: miniTerrain.addPricingPeriod,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (miniTerrain.pricingPeriods.isEmpty) {
              return const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sans période spécifique, le prix 1h entier est utilisé.',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                ),
              );
            }

            return Column(
              children: miniTerrain.pricingPeriods.map((period) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildPricingPeriodRow(miniTerrain, period),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPricingPeriodRow(
    _SubTerrainDraft miniTerrain,
    _PricingPeriodDraft period,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E0D8)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactField(
                  label: 'Nom',
                  ctrl: period.labelCtrl,
                  hint: 'Soirée',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => miniTerrain.removePricingPeriod(period),
                icon: const Icon(
                  PhosphorIconsLight.x,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CompactField(
                  label: 'Début',
                  ctrl: period.startCtrl,
                  hint: '18:00',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactField(
                  label: 'Fin',
                  ctrl: period.endCtrl,
                  hint: '23:00',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CompactField(
                  label: 'Prix 1h',
                  ctrl: period.priceCtrl,
                  hint: '20000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _dayLabels.entries.map((entry) {
                  final selected = period.days.contains(entry.key);
                  return _DivisionChip(
                    label: entry.value,
                    selected: selected,
                    onTap: () {
                      if (selected) {
                        period.days.remove(entry.key);
                      } else {
                        period.days.add(entry.key);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Aucun jour sélectionné = tous les jours.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
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
    _editingTerrainIndex.value = _miniTerrains.length - 1;
    _step.value = 3;
  }

  Widget _buildFormatsSelector(_SubTerrainDraft miniTerrain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formats disponibles',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _miniTerrainTypes.map((type) {
              final selected = miniTerrain.formats.contains(type);
              return _DivisionChip(
                label: type,
                selected: selected,
                onTap: () {
                  if (selected && miniTerrain.formats.length > 1) {
                    miniTerrain.formats.remove(type);
                  } else if (!selected) {
                    miniTerrain.formats.add(type);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
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

  // ── 5. Localisation ───────────────────────────────────────────────────────
  Widget _buildLocationSection() => _Card(
    title: 'Localisation',
    icon: PhosphorIconsLight.mapPin,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: _isLocating.value ? null : _useCurrentLocation,
              icon: _isLocating.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(PhosphorIconsLight.gps, size: 18),
              label: Text(
                _isLocating.value
                    ? 'Détection en cours...'
                    : 'Utiliser ma position actuelle',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006F39),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _addressCtrl,
          builder: (context, value, child) {
            final address = value.text.trim();
            if (address.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 12),
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
                    child: Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );

  // ── 6. Navigation ────────────────────────────────────────────────────────
  Widget _buildBottomBar() => Obx(() {
    final isLast = _step.value == 4;
    final isTerrainEditor = _step.value == 3;
    final canGoBack = _step.value > 0;
    final label = isLast
        ? 'Confirmer'
        : isTerrainEditor
            ? 'Valider ce terrain'
            : _step.value == 2 && _miniTerrains.isEmpty
                ? 'Ajouter un terrain'
                : _step.value == 2
                    ? 'Voir le récapitulatif'
                    : 'Continuer';

    return Row(
      children: [
        if (canGoBack) ...[
          SizedBox(
            width: 52,
            height: 52,
            child: OutlinedButton(
              onPressed: _isSaving.value ? null : _goPrevious,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(PhosphorIconsLight.arrowLeft, size: 20),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving.value ? null : _goNext,
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
                    children: [
                      Icon(
                        isLast
                            ? PhosphorIconsLight.checkCircle
                            : PhosphorIconsLight.arrowRight,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  });

  void _goPrevious() {
    if (_step.value == 3) {
      _step.value = 2;
      return;
    }
    if (_step.value == 4) {
      _step.value = 2;
      return;
    }
    if (_step.value > 0) _step.value--;
  }

  Future<void> _goNext() async {
    if (_step.value == 0 && !_validateComplexInfo()) return;
    if (_step.value == 2 && _miniTerrains.isEmpty) {
      _addMiniTerrain();
      return;
    }
    if (_step.value == 2) {
      _step.value = 4;
      return;
    }
    if (_step.value == 3) {
      if (!_validateCurrentTerrain()) return;
      _step.value = 2;
      return;
    }
    if (_step.value == 4) {
      await _onSave();
      return;
    }
    _step.value++;
  }

  bool _validateComplexInfo() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez saisir un nom de complexe',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez sélectionner une adresse ou utiliser la position actuelle',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  bool _validateCurrentTerrain() {
    final index = _editingTerrainIndex.value;
    if (index == null || index < 0 || index >= _miniTerrains.length) {
      return false;
    }
    final fallbackPrice = int.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (fallbackPrice <= 0) _priceCtrl.text = '10000';
    final valid = _miniTerrains[index].toModels(
      index,
      int.tryParse(_priceCtrl.text.trim()) ?? 10000,
    );
    if (valid == null) {
      Get.snackbar(
        'Terrain incomplet',
        'Vérifiez le nom, les formats, les découpes et les règles tarifaires',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

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
      final models = _miniTerrains[i].toModels(i, price);
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
        'Chaque terrain physique doit avoir un nom, un format, une capacité valide, des tarifs valides et au moins une découpe réservable',
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

class _TerrainDraftTile extends StatelessWidget {
  final int index;
  final _SubTerrainDraft terrain;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _TerrainDraftTile({
    required this.index,
    required this.terrain,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final formats = terrain.formats.isEmpty
          ? 'Aucun format'
          : terrain.formats.join(', ');
      final cuts = [
        if (terrain.allowFull.value) 'Full',
        if (terrain.allowHalf.value) 'Moitié',
        if (terrain.allowThird.value) 'Tiers',
      ].join(', ');
      final price = terrain.priceCtrl.text.trim().isEmpty
          ? 'Prix par défaut'
          : '${terrain.priceCtrl.text.trim()} F/h';

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAF7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E0D8)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF006F39),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terrain.nameCtrl.text.trim().isEmpty
                        ? 'Terrain ${index + 1}'
                        : terrain.nameCtrl.text.trim(),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$formats · ${cuts.isEmpty ? 'Aucune découpe' : cuts} · $price',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                PhosphorIconsLight.pencilSimple,
                color: Color(0xFF006F39),
                size: 18,
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  PhosphorIconsLight.trash,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ReviewLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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

class _CompactField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;

  const _CompactField({
    required this.label,
    required this.ctrl,
    required this.hint,
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
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 42,
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAF7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E0D8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E0D8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF006F39)),
              ),
            ),
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
