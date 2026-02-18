import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_search_provider.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/provider_search_card.dart';
import '../widgets/search_filters_sheet.dart';

/// Pantalla principal de busqueda de proveedores.
/// Es el contenido del tab "Buscar" en el bottom nav del modo Cliente.
class ProviderSearchScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ProviderSearchScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ProviderSearchScreen> createState() =>
      _ProviderSearchScreenState();
}

class _ProviderSearchScreenState
    extends ConsumerState<ProviderSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Cargar categorias y busqueda inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();

      // Si hay una categoria inicial (viene de query param), aplicarla
      if (widget.initialCategory != null) {
        ref
            .read(providerSearchProvider.notifier)
            .setCategoryBySlug(widget.initialCategory);
      } else {
        ref.read(providerSearchProvider.notifier).search();
      }
    });

    // Infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(providerSearchProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(providerSearchProvider.notifier).setSearchQuery(
            value.isEmpty ? null : value,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final searchState = ref.watch(providerSearchProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: titulo + filtros
            _buildHeader(colors, textTheme, searchState),
            // Barra de busqueda
            _buildSearchBar(colors),
            const SizedBox(height: 8),
            // Chips de categorias
            const CategoryFilterChips(),
            const SizedBox(height: 8),
            // Resultados
            Expanded(
              child: _buildResults(colors, textTheme, searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppColorsExtension colors,
    TextTheme textTheme,
    ProviderSearchState searchState,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Text(
            'Buscar expertos',
            style: textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Boton de filtros
          Stack(
            children: [
              IconButton(
                onPressed: () => SearchFiltersSheet.show(context),
                icon: Icon(
                  Icons.tune_rounded,
                  color: searchState.hasActiveFilters
                      ? colors.primary
                      : colors.textSecondary,
                ),
              ),
              if (searchState.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o servicio...',
          prefixIcon: Icon(
            Icons.search,
            color: colors.textHint,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(providerSearchProvider.notifier)
                        .setSearchQuery(null);
                  },
                  icon: Icon(
                    Icons.close,
                    color: colors.textHint,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildResults(
    AppColorsExtension colors,
    TextTheme textTheme,
    ProviderSearchState searchState,
  ) {
    // Estado de carga inicial
    if (searchState.isLoading && searchState.providers.isEmpty) {
      return _buildLoadingSkeleton(colors);
    }

    // Estado de error
    if (searchState.errorMessage != null && searchState.providers.isEmpty) {
      return _buildErrorState(colors, textTheme, searchState.errorMessage!);
    }

    // Estado vacio
    if (!searchState.isLoading && searchState.providers.isEmpty) {
      return _buildEmptyState(colors, textTheme);
    }

    // Resultados
    return RefreshIndicator(
      onRefresh: () => ref.read(providerSearchProvider.notifier).refresh(),
      color: colors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: searchState.providers.length +
            (searchState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator al final
          if (index >= searchState.providers.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            );
          }

          final provider = searchState.providers[index];
          return ProviderSearchCard(
            provider: provider,
            onTap: () {
              // Navegar al perfil del proveedor
              context.push(
                '/provider-profile/${provider.id}',
                extra: {
                  'providerName': provider.fullName,
                  'providerAvatarUrl': provider.avatarUrl,
                  'providerRating': provider.rating,
                  'providerBio': provider.bio,
                  'categories': provider.categories
                      .map((c) => c.slug)
                      .toList(),
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton(AppColorsExtension colors) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceVariant,
      highlightColor: colors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _SkeletonCard();
        },
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: colors.textHint.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron proveedores',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros o buscar con otros terminos',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(providerSearchProvider.notifier).clearFilters();
              },
              icon: Icon(Icons.refresh, color: colors.primary),
              label: Text(
                'Limpiar filtros',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    AppColorsExtension colors,
    TextTheme textTheme,
    String error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ocurrio un error',
              style: textTheme.titleLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(providerSearchProvider.notifier).search();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton card para el estado de carga.
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar skeleton
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre skeleton
                Container(
                  width: 160,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Rating skeleton
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                // Chips skeleton
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 80,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Precio skeleton
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
