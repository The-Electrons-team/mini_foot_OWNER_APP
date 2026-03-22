import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Widget shimmer de base avec animation native ───────────────────────────
// Pas de package externe ! On utilise un AnimatedBuilder + LinearGradient
// pour creer l'effet de brillance qui se deplace de gauche a droite.

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // L'animation tourne en boucle toutes les 1.5 secondes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              // Le gradient se deplace grace a _controller.value (0 -> 1)
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1, 0),
              colors: const [
                kBgSurface, // couleur de base (beige)
                kBgCard, // point lumineux (blanc)
                kBgSurface, // retour a la couleur de base
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── TerrainCardSkeleton ────────────────────────────────────────────────────
// Simule le look de la carte terrain : image en haut, stats au milieu, actions

class TerrainCardSkeleton extends StatelessWidget {
  const TerrainCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone image (180px de haut, coins arrondis en haut)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: ShimmerBox(
              width: double.infinity,
              height: 180,
              borderRadius: 0,
            ),
          ),

          // Contenu sous l'image
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row de 3 stats (petites pilules)
                Row(
                  children: [
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 36, borderRadius: 10),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 36, borderRadius: 10),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 36, borderRadius: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Barre de progression simulee
                ShimmerBox(width: double.infinity, height: 6, borderRadius: 4),
                const SizedBox(height: 12),

                // Divider
                Container(height: 1, color: kDivider),
                const SizedBox(height: 8),

                // Actions row (toggle + 2 boutons)
                Row(
                  children: [
                    ShimmerBox(width: 90, height: 34, borderRadius: 20),
                    const Spacer(),
                    ShimmerBox(width: 40, height: 40, borderRadius: 12),
                    const SizedBox(width: 8),
                    ShimmerBox(width: 40, height: 40, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ReservationCardSkeleton ────────────────────────────────────────────────
// Simule une carte reservation : avatar + lignes de texte + badge statut

class ReservationCardSkeleton extends StatelessWidget {
  const ReservationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Column(
        children: [
          // Top row : avatar + nom + badge
          Row(
            children: [
              // Avatar carre arrondi
              ShimmerBox(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 12),
              // Nom + equipe (2 lignes)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 14, borderRadius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 12, borderRadius: 6),
                  ],
                ),
              ),
              // Badge statut
              ShimmerBox(width: 80, height: 30, borderRadius: 8),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: kDivider),
          const SizedBox(height: 14),

          // Bottom : terrain + horaire
          Row(
            children: [
              ShimmerBox(width: 32, height: 32, borderRadius: 8),
              const SizedBox(width: 8),
              ShimmerBox(width: 100, height: 12, borderRadius: 6),
              const Spacer(),
              ShimmerBox(width: 80, height: 12, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 10),
          // Date + montant
          Row(
            children: [
              ShimmerBox(width: 90, height: 12, borderRadius: 6),
              const Spacer(),
              ShimmerBox(width: 80, height: 16, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── NotificationCardSkeleton ───────────────────────────────────────────────
// Simule une notification : icone ronde + lignes de texte

class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          // Icone ronde
          ShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: 12),
          // Lignes de texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14, borderRadius: 6),
                const SizedBox(height: 8),
                ShimmerBox(width: 180, height: 12, borderRadius: 6),
                const SizedBox(height: 6),
                ShimmerBox(width: 80, height: 10, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ShimmerList ────────────────────────────────────────────────────────────
// Widget generique qui affiche 4 items shimmer avec padding.
// Tu lui passes un itemBuilder et il genere la liste de skeletons.

class ShimmerList extends StatelessWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ShimmerList({
    super.key,
    required this.itemBuilder,
    this.itemCount = 4,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 100),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
