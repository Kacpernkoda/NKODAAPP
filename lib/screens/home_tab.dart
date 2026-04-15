import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import 'products/product_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  static const String _baseUrl = 'https://wljdozodcnzslcqbrpwu.supabase.co/storage/v1/object/public/Grafiki%20home';

  static final List<Map<String, dynamic>> _products = [
    {
      'name': 'SL7.5',
      'thickness': '190 μm',
      'material': 'TPU',
      'finish': 'Połysk',
      'gloss': '94.5',
      'warranty': '5 lat',
      'specUrl': '$_baseUrl/nkoda-sl75-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/SL7.5.webp',
      'desc': 'Podstawowa ochrona w premium TPU z wzmocnionym połyskiem.',
      'features': ['Wzmocniony połysk', 'Termiczna samoregeneracja', 'Brak żółknięcia', 'Maksymalna elastyczność'],
    },
    {
      'name': 'SATIN',
      'thickness': '190 μm',
      'material': 'TPU',
      'finish': 'Satyna',
      'gloss': '18.7',
      'warranty': '10 lat',
      'specUrl': '$_baseUrl/nkoda-satin-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/SATIN.webp',
      'desc': 'Satynowe wykończenie z potężną tarczą ochronną.',
      'features': ['Satynowy efekt', 'Termiczna samoregeneracja', 'Odporność na chemię', 'Doskonała ochrona'],
    },
    {
      'name': 'MATTE',
      'thickness': '190 μm',
      'material': 'TPU',
      'finish': 'Mat',
      'gloss': '28.5',
      'warranty': '10 lat',
      'specUrl': '$_baseUrl/nkoda-matte-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/MATTE.webp',
      'desc': 'Głęboka matowa tekstura i ekstremalna odporność.',
      'features': ['Głęboki mat', 'Termiczna samoregeneracja', 'Brak żółknięcia', 'Wysoka elastyczność'],
    },
    {
      'name': 'PRO',
      'thickness': '200 μm',
      'material': 'TPU',
      'finish': 'Super Połysk',
      'gloss': '97.0',
      'warranty': 'Dożywotnia',
      'specUrl': '$_baseUrl/nkoda-pro-wzor-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/PRO.webp',
      'desc': 'Nasz flagowiec. Maksymalna trwałość i lustrzany blask.',
      'features': ['Maksymalny połysk', 'Superior self-healing', 'Najwyższa trwałość', 'Klasa Premium'],
    },
    {
      'name': 'OFF-ROAD12',
      'thickness': '300 μm',
      'material': 'TPU',
      'finish': 'Połysk',
      'gloss': '95.3',
      'warranty': '10 lat',
      'specUrl': '$_baseUrl/nkoda-offroad12-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/OFF-ROAD.webp',
      'desc': 'Ekstremalna grubość stworzona na najtrudniejsze terenowe wyzwania.',
      'features': ['Ekstremalna grubość 300μm', 'Ochrona przed uderzeniami', 'Pancerna powłoka', 'Termo-regeneracja'],
    },
    {
      'name': 'HEAT',
      'thickness': '200 μm',
      'material': 'TPU',
      'finish': 'Super Połysk',
      'gloss': '94.7',
      'warranty': 'Dożywotnia',
      'specUrl': '$_baseUrl/nkoda-heat-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/HEAT.webp',
      'desc': 'Specjalna technologia TPU z wzmocnionym klejem na wysokie temperatury.',
      'features': ['Wzmocniony klej', 'Odporność na upały', 'Szybka regeneracja', 'Wysoki blask'],
    },
    {
      'name': 'PRO WIDE',
      'thickness': '200 μm',
      'material': 'TPU',
      'finish': 'Super Połysk',
      'gloss': '97.0',
      'warranty': 'Dożywotnia',
      'specUrl': '$_baseUrl/nkoda-prowide-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/PROWIDE.webp',
      'desc': 'Najszersze arkusze na świecie dla dużych powierzchni bez łączeń.',
      'features': ['Szerokość 1.83m', 'Brak łączeń na masce', 'Najwyższy połysk', 'Efekt lustra'],
    },
    {
      'name': 'LUMINA',
      'thickness': '200 μm',
      'material': 'TPU',
      'finish': 'Połysk / Fluo',
      'gloss': '94.8',
      'warranty': '8 lat',
      'specUrl': '$_baseUrl/nkoda-lumina-pl-specyfikacja.webp',
      'thumbUrl': '$_baseUrl/LUMINA.webp',
      'desc': 'Najwyższy blask i unikalny efekt fluorescencyjny (świeci w ciemności).',
      'features': ['Świeci w ciemności', 'Efekt Lumina', 'Wysoka przejrzystość', 'Termo-regeneracja'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar(context)),
          SliverToBoxAdapter(child: _buildAboutSection(context)),
          SliverToBoxAdapter(child: _buildWelcomeHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.medium),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildProductCard(context, _products[index]),
                childCount: _products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.large, vertical: AppPadding.extraLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
                height: 1.1,
              ),
              children: [
                const TextSpan(text: 'PRODUCENT FOLII PPF\nZ PONAD 30 PATENTAMI I\n'),
                TextSpan(
                  text: 'ZAAWANSOWANĄ\nNANOTECHNOLOGIĄ\nTPU.',
                  style: TextStyle(color: AppColors.accentRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'NKODA to marka z tradycjami i nowoczesnym podejściem. Jesteśmy jednym z globalnych liderów rynku, z fabrykami w Chinach i magazynami w Europie zapewniającymi powtarzalność i ciągłość dostaw.\n\nOferujemy najwyższej jakości produkty wykonane w nanotechnologii TPU potwierdzonej ponad 30 uzyskanymi patentami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSilver.withOpacity(0.9),
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'ppf@nkodaeurope.com',
                );
                if (await canLaunchUrl(emailLaunchUri)) {
                  await launchUrl(emailLaunchUri);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                elevation: 8,
              ),
              child: const Text(
                'SKONTAKTUJ SIĘ Z NAMI',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.white10, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppPadding.medium, AppPadding.medium, AppPadding.medium, 0),
      child: Center(
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/images/logo_v4.png',
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.car_repair, color: AppColors.accentRed, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produkty Bezbarwne',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            'Zaawansowana ochrona lakieru PPF',
            style: TextStyle(color: AppColors.textSilver.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Hero(
        tag: 'prod_${product['name']}',
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.accentRed.withOpacity(0.2), width: 1),
            image: product['thumbUrl'] != null 
              ? DecorationImage(
                  image: NetworkImage(product['thumbUrl']!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                )
              : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline, color: Colors.white70, size: 18),
                ),
              ),
              const Spacer(),
              Text(
                product['name']!,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
              ),
              Text(
                product['thickness']!,
                style: TextStyle(color: AppColors.accentRed, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
