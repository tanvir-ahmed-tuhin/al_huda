import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  final _currencyFormat = NumberFormat('#,##,###', 'bn_BD');

  // Asset Controllers
  final _cashController = TextEditingController();
  final _bankController = TextEditingController();
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _businessStockController = TextEditingController();
  final _receivablesController = TextEditingController();
  final _investmentsController = TextEditingController();

  // Liability Controllers
  final _debtsController = TextEditingController();
  final _expensesController = TextEditingController();

  // Nisab threshold (approximate current silver Nisab in BDT, editable by user)
  double _nisabThreshold = 105000.0;
  final _nisabController = TextEditingController(text: '105000');

  double _totalAssets = 0.0;
  double _totalLiabilities = 0.0;
  double _netZakatableWealth = 0.0;
  double _zakatPayable = 0.0;
  bool _isEligible = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    final controllers = [
      _cashController,
      _bankController,
      _goldController,
      _silverController,
      _businessStockController,
      _receivablesController,
      _investmentsController,
      _debtsController,
      _expensesController,
      _nisabController,
    ];

    for (final c in controllers) {
      c.addListener(_calculateZakat);
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _businessStockController.dispose();
    _receivablesController.dispose();
    _investmentsController.dispose();
    _debtsController.dispose();
    _expensesController.dispose();
    _nisabController.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) {
    final text = c.text.trim().replaceAll(',', '');
    return double.tryParse(text) ?? 0.0;
  }

  void _calculateZakat() {
    final cash = _parse(_cashController);
    final bank = _parse(_bankController);
    final gold = _parse(_goldController);
    final silver = _parse(_silverController);
    final stock = _parse(_businessStockController);
    final receivables = _parse(_receivablesController);
    final investments = _parse(_investmentsController);

    final debts = _parse(_debtsController);
    final expenses = _parse(_expensesController);

    _nisabThreshold = _parse(_nisabController);
    if (_nisabThreshold <= 0) _nisabThreshold = 105000.0;

    final assets = cash + bank + gold + silver + stock + receivables + investments;
    final liabilities = debts + expenses;
    final net = assets - liabilities;

    setState(() {
      _totalAssets = assets;
      _totalLiabilities = liabilities;
      _netZakatableWealth = net > 0 ? net : 0.0;
      _isEligible = _netZakatableWealth >= _nisabThreshold;
      _zakatPayable = _isEligible ? (_netZakatableWealth * 0.025) : 0.0;
    });
  }

  void _resetAll() {
    _cashController.clear();
    _bankController.clear();
    _goldController.clear();
    _silverController.clear();
    _businessStockController.clear();
    _receivablesController.clear();
    _investmentsController.clear();
    _debtsController.clear();
    _expensesController.clear();
    _calculateZakat();
  }

  void _copyResult() {
    final text = '''
আল-হুদা যাকাত হিসাব:
মোট যাকাতযোগ্য সম্পদ: ৳${_currencyFormat.format(_totalAssets.round())}
মোট দেনা ও ঋণ: ৳${_currencyFormat.format(_totalLiabilities.round())}
নীট সম্পদ: ৳${_currencyFormat.format(_netZakatableWealth.round())}
নিসাব সীমা: ৳${_currencyFormat.format(_nisabThreshold.round())}
যাকাতযোগ্য স্ট্যাটাস: ${_isEligible ? "ফরজ (যোগ্য)" : "অযোগ্য (নিসাব পূর্ণ হয়নি)"}
প্রদেয় যাকাত (২.৫%): ৳${_currencyFormat.format(_zakatPayable.round())}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 18),
            SizedBox(width: 8),
            Text('যাকাতের হিসাব কপি করা হয়েছে!'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'যাকাত ক্যালকুলেটর',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accentGold),
            tooltip: 'রিসেট করুন',
            onPressed: _resetAll,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.accentGold),
            tooltip: 'হিসাব কপি করুন',
            onPressed: _copyResult,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Result Hero Card
          IslamicCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(18),
            borderColor: AppColors.accentGold,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E3A2B), const Color(0xFF0F261B)]
                  : [const Color(0xFFEAF8F0), const Color(0xFFD4EFE0)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          FlutterIslamicIcons.zakat,
                          color: AppColors.accentGold,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'প্রদেয় যাকাত (২.৫%)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: _isEligible
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isEligible ? Colors.green : Colors.grey,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _isEligible ? 'যাকাত ফরজ' : 'নিসাব অপূর্ণ',
                        style: TextStyle(
                          color: _isEligible ? Colors.green : Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '৳ ${_currencyFormat.format(_zakatPayable.round())}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('মোট সম্পদ', _totalAssets, isDark),
                    _buildSummaryItem('মোট দেনা', _totalLiabilities, isDark),
                    _buildSummaryItem('নীট যাকাতযোগ্য', _netZakatableWealth, isDark),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nisab Settings Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentGold),
                        SizedBox(width: 6),
                        Text(
                          'নিসাব নির্ধারণ (রৌপ্য নিসাব)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '৫২.৫ তোলা রূপা',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'বর্তমানে নিসাব পরিমাণ মূল্য:',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _nisabController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          prefixText: '৳ ',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.accentGold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Section 1: Assets
          const Text(
            '১. যাকাতযোগ্য সম্পদসমূহ (টাকায়)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _cashController,
            label: 'নগদ টাকা (হাতে রক্ষিত)',
            hint: '০',
            icon: Icons.money_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _bankController,
            label: 'ব্যাংক একাউন্ট ও ডিপিএস ব্যালেন্স',
            hint: '০',
            icon: Icons.account_balance_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _goldController,
            label: 'স্বর্ণের বর্তমান বাজারমূল্য',
            hint: '০',
            icon: Icons.diamond_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _silverController,
            label: 'রূপার বর্তমান বাজারমূল্য',
            hint: '০',
            icon: Icons.circle_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _businessStockController,
            label: 'ব্যবসায়িক পণ্য ও মজুদ মালের মূল্য',
            hint: '০',
            icon: Icons.storefront_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _receivablesController,
            label: 'অন্যের কাছে পাওনা অর্থ (যা ফেরত পাওয়ার আশা আছে)',
            hint: '০',
            icon: Icons.handshake_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _investmentsController,
            label: 'শেয়ার, সঞ্চয়পত্র ও অন্যান্য বিনিয়োগ',
            hint: '০',
            icon: Icons.trending_up_rounded,
            isDark: isDark,
          ),

          const SizedBox(height: 22),

          // Section 2: Liabilities
          const Text(
            '২. দেনা ও ঋণসমূহ (বাদ যাবে)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _debtsController,
            label: 'বর্তমানে পরিশোধযোগ্য ব্যক্তিগত ঋণ',
            hint: '০',
            icon: Icons.credit_card_off_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          _buildInputField(
            controller: _expensesController,
            label: 'বকেয়া বিল, বেতন ও চলতি খরচ',
            hint: '০',
            icon: Icons.receipt_long_rounded,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Zakat Recipients Guide (Quran Surah At-Tawbah: 60)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF7FBF8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(FlutterIslamicIcons.quran, color: AppColors.accentGold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'যাকাত বণ্টনের ৮টি খাত (সূরা আত-তাওবাহ: ৬০)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '১. দরিদ্র ও নিঃস্ব (ফকির)\n'
                  '২. সম্বলহীন অভাবী (মিসকিন)\n'
                  '৩. যাকাত আদায়ে নিয়োজিত কর্মকর্তা\n'
                  '৪. ইসলামের প্রতি আকৃষ্ট করার উদ্দেশ্যে\n'
                  '৫. দাসমুক্তির জন্য\n'
                  '৬. ঋণগ্রস্ত ব্যক্তি (ঋণ পরিশোধে অক্ষম)\n'
                  '৭. আল্লাহর পথে জিহাদ ও দ্বীনি খেদমত\n'
                  '৮. মুসাফির বা পথচারী',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, double value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '৳ ${_currencyFormat.format(value.round())}',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkCard,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    hintText: hint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    border: InputBorder.none,
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
