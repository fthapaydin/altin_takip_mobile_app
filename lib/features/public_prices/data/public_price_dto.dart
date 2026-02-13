import 'package:altin_takip/features/public_prices/domain/public_price.dart';
import 'package:altin_takip/features/public_prices/domain/public_prices_data.dart';

/// DTO for parsing public API response
class PublicPricesDataDto extends PublicPricesData {
  const PublicPricesDataDto({
    required super.updateDate,
    required super.currencies,
    required super.goldPrices,
  });

  factory PublicPricesDataDto.fromJson(Map<String, dynamic> json) {
    final updateDate = json['Update_Date'] as String? ?? '';

    final currencies = <PublicPrice>[];
    final goldPrices = <PublicPrice>[];

    // Define currency codes (Döviz) - Top 15 most popular
    const currencyCodes = [
      'USD',
      'EUR',
      'GBP',
      'CHF',
      'CAD',
      'AUD',
      'JPY',
      'SAR',
      'KWD',
      'AED',
      'CNY',
      'RUB',
      'SEK',
      'NOK',
      'DKK',
    ];

    // Define gold codes (Altın) - Essential items only
    const goldCodes = [
      'gram-altin',
      'ceyrek-altin',
      'yarim-altin',
      'tam-altin',
      'cumhuriyet-altini',
      'ata-altin',
      '22-ayar-bilezik',
      'gumus',
    ];

    // Map for display names
    final displayNames = {
      'USD': 'Amerikan Doları',
      'EUR': 'Euro',
      'GBP': 'İngiliz Sterlini',
      'CHF': 'İsviçre Frangı',
      'CAD': 'Kanada Doları',
      'RUB': 'Rus Rublesi',
      'AED': 'BAE Dirhemi',
      'AUD': 'Avustralya Doları',
      'DKK': 'Danimarka Kronu',
      'SEK': 'İsveç Kronu',
      'NOK': 'Norveç Kronu',
      'JPY': 'Japon Yeni',
      'KWD': 'Kuveyt Dinarı',
      'ZAR': 'Güney Afrika Randı',
      'BHD': 'Bahreyn Dinarı',
      'LYD': 'Libya Dinarı',
      'SAR': 'Suudi Arabistan Riyali',
      'IQD': 'Irak Dinarı',
      'ILS': 'İsrail Şekeli',
      'IRR': 'İran Riyali',
      'INR': 'Hindistan Rupisi',
      'MXN': 'Meksika Pesosu',
      'HUF': 'Macar Forinti',
      'NZD': 'Yeni Zelanda Doları',
      'BRL': 'Brezilya Reali',
      'IDR': 'Endonezya Rupisi',
      'CZK': 'Çek Kronu',
      'PLN': 'Polonya Zlotisi',
      'RON': 'Rumen Leyi',
      'CNY': 'Çin Yuanı',
      'ARS': 'Arjantin Pesosu',
      'ALL': 'Arnavutluk Leki',
      'AZN': 'Azerbaycan Manatı',
      'BAM': 'Bosna Markı',
      'CLP': 'Şili Pesosu',
      'COP': 'Kolombiya Pesosu',
      'CRC': 'Kosta Rika Kolonu',
      'DZD': 'Cezayir Dinarı',
      'EGP': 'Mısır Lirası',
      'HKD': 'Hong Kong Doları',
      'ISK': 'İzlanda Kronu',
      'KRW': 'Güney Kore Wonu',
      'KZT': 'Kazakistan Tengesi',
      'LBP': 'Lübnan Lirası',
      'LKR': 'Sri Lanka Rupisi',
      'MAD': 'Fas Dirhemi',
      'MDL': 'Moldova Leyi',
      'MKD': 'Makedonya Dinarı',
      'MYR': 'Malezya Ringgiti',
      'OMR': 'Umman Riyali',
      'PEN': 'Peru Solu',
      'PHP': 'Filipin Pesosu',
      'PKR': 'Pakistan Rupisi',
      'QAR': 'Katar Riyali',
      'RSD': 'Sırp Dinarı',
      'SGD': 'Singapur Doları',
      'SYP': 'Suriye Lirası',
      'THB': 'Tayland Bahtı',
      'TWD': 'Tayvan Doları',
      'UAH': 'Ukrayna Grivnası',
      'UYU': 'Uruguay Pesosu',
      'GEL': 'Gürcistan Larisi',
      'TND': 'Tunus Dinarı',
      'BGN': 'Bulgar Levası',
      'ons': 'Ons Altın',
      'gram-altin': 'Gram Altın',
      'gram-has-altin': 'Gram Has Altın',
      'ceyrek-altin': 'Çeyrek Altın',
      'yarim-altin': 'Yarım Altın',
      'tam-altin': 'Tam Altın',
      'cumhuriyet-altini': 'Cumhuriyet Altını',
      'ata-altin': 'Ata Altın',
      '14-ayar-altin': '14 Ayar Altın',
      '18-ayar-altin': '18 Ayar Altın',
      '22-ayar-bilezik': '22 Ayar Bilezik',
      'ikibucuk-altin': '2.5 Altın',
      'besli-altin': 'Beşli Altın',
      'gremse-altin': 'Gremse Altın',
      'resat-altin': 'Reşat Altın',
      'hamit-altin': 'Hamit Altın',
      'gumus': 'Gümüş',
      'gram-platin': 'Gram Platin',
      'gram-paladyum': 'Gram Paladyum',
    };

    // Parse currencies
    for (final code in currencyCodes) {
      final data = json[code];
      if (data != null && data is Map<String, dynamic>) {
        currencies.add(
          PublicPrice(
            code: code,
            name: displayNames[code] ?? code,
            type: data['Tür'] as String? ?? 'Döviz',
            buyPrice: data['Alış'] as String? ?? '-',
            sellPrice: data['Satış'] as String? ?? '-',
            change: data['Değişim'] as String? ?? '%0,00',
          ),
        );
      }
    }

    // Parse gold prices
    for (final code in goldCodes) {
      final data = json[code];
      if (data != null && data is Map<String, dynamic>) {
        goldPrices.add(
          PublicPrice(
            code: code,
            name: displayNames[code] ?? code,
            type: data['Tür'] as String? ?? 'Altın',
            buyPrice: data['Alış'] as String? ?? '-',
            sellPrice: data['Satış'] as String? ?? '-',
            change: data['Değişim'] as String? ?? '%0,00',
          ),
        );
      }
    }

    return PublicPricesDataDto(
      updateDate: updateDate,
      currencies: currencies,
      goldPrices: goldPrices,
    );
  }
}
