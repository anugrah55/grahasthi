import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/grocery_provider.dart';

class AddGroceryScreen extends StatefulWidget {
  const AddGroceryScreen({super.key});

  @override
  State<AddGroceryScreen> createState() => _AddGroceryScreenState();
}

class _AddGroceryScreenState extends State<AddGroceryScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _storeController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'sabzi';
  String _selectedPaymentMode = 'cash';
  DateTime _selectedDate = DateTime.now();

  List<String> _itemSuggestions = [];
  List<String> _storeSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() async {
    final grocery = context.read<GroceryProvider>();
    _itemSuggestions = await grocery.getItemSuggestions();
    _storeSuggestions = await grocery.getStoreSuggestions();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.t;

    return Scaffold(
      appBar: AppBar(title: Text(t('add_item'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item name with autocomplete
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _itemSuggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                _nameController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: t('item_name'),
                    prefixIcon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  onChanged: (val) => _nameController.text = val,
                );
              },
              onSelected: (val) => _nameController.text = val,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            Text(t('category'), style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.groceryCategories.map((cat) {
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(AppLocalizations.categoryName(cat)),
                  selected: selected,
                  selectedColor: GrahasthiTheme.saffron.withOpacity(0.3),
                  backgroundColor: GrahasthiTheme.surfaceLight,
                  side: BorderSide(color: selected ? GrahasthiTheme.saffron : GrahasthiTheme.cardBorder),
                  labelStyle: TextStyle(
                    color: selected ? GrahasthiTheme.saffron : GrahasthiTheme.textSecondary,
                    fontSize: 13,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t('amount'),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                  builder: (ctx, child) => Theme(
                    data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: GrahasthiTheme.saffron)),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: t('date'),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: GrahasthiTheme.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Store (autocomplete)
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _storeSuggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: t('bought_from'),
                    prefixIcon: const Icon(Icons.store),
                  ),
                  onChanged: (val) => _storeController.text = val,
                );
              },
              onSelected: (val) => _storeController.text = val,
            ),
            const SizedBox(height: 16),

            // Payment mode
            Text(t('payment_mode'), style: const TextStyle(fontSize: 14, color: GrahasthiTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: AppConstants.paymentModes.map((mode) {
                final selected = _selectedPaymentMode == mode;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(AppLocalizations.paymentModeName(mode)),
                      selected: selected,
                      selectedColor: GrahasthiTheme.saffron.withOpacity(0.3),
                      backgroundColor: GrahasthiTheme.surfaceLight,
                      side: BorderSide(color: selected ? GrahasthiTheme.saffron : GrahasthiTheme.cardBorder),
                      labelStyle: TextStyle(
                        color: selected ? GrahasthiTheme.saffron : GrahasthiTheme.textSecondary,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _selectedPaymentMode = mode),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: t('add_note'),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveItem,
                child: Text(t('save'), style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveItem() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.t('field_required'))),
      );
      return;
    }

    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    context.read<GroceryProvider>().addItem(
      name: name,
      category: _selectedCategory,
      amount: amount,
      date: dateStr,
      store: _storeController.text.trim(),
      paymentMode: _selectedPaymentMode,
      note: _noteController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.t('saved_successfully'))),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _storeController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
