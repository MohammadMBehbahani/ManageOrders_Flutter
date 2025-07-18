import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/models/manageleftview.dart';
import 'package:manageorders/providers/manage_left_view_provider.dart';

class ManageLeftViewScreen extends ConsumerStatefulWidget {
  const ManageLeftViewScreen({super.key});

  @override
  ConsumerState<ManageLeftViewScreen> createState() => _ManageLeftViewScreenState();
}

class _ManageLeftViewScreenState extends ConsumerState<ManageLeftViewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _id = 'singleton_view'; // or you can use UUID().v4() once
  final _fsCategoryController = TextEditingController();
  final _fsProductController = TextEditingController();
  final _bwProductController = TextEditingController();
  final _bhCategoryController = TextEditingController();
  final _bwCategoryController = TextEditingController();
  final _bhProductController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loadExisting() async {
    final existing = await ref.read(manageLeftViewProvider.notifier).getViewById(_id);
    if (existing != null) {
      _fsCategoryController.text = existing.fontsizecategory?.toString() ?? '';
      _fsProductController.text = existing.fontsizeproduct?.toString() ?? '';
      _bwProductController.text = existing.boxwidthproduct?.toString() ?? '';
      _bhCategoryController.text = existing.boxheightcategory?.toString() ?? '';
      _bwCategoryController.text = existing.boxwidthcategory?.toString() ?? '';
      _bhProductController.text = existing.boxheightproduct?.toString() ?? '';
    }
  }

  Future<void> _saveView() async {
    setState(() => _isLoading = true);

    final view = ManageLeftView(
      id: _id,
      fontsizecategory: int.tryParse(_fsCategoryController.text),
      fontsizeproduct: int.tryParse(_fsProductController.text),
      boxwidthproduct: int.tryParse(_bwProductController.text),
      boxheightcategory: int.tryParse(_bhCategoryController.text),
      boxwidthcategory: int.tryParse(_bwCategoryController.text),
      boxheightproduct: int.tryParse(_bhProductController.text),
    );

    try {
      await ref.read(manageLeftViewProvider.notifier).addOrUpdateView(view);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _fsCategoryController.dispose();
    _fsProductController.dispose();
    _bwProductController.dispose();
    _bhCategoryController.dispose();
    _bwCategoryController.dispose();
    _bhProductController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage View Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNumberField('Font Size Category', _fsCategoryController),
              _buildNumberField('Box Height Category', _bhCategoryController),
              _buildNumberField('Box Width Category', _bwCategoryController),
              _buildNumberField('Font Size Product', _fsProductController),
              _buildNumberField('Box Height Product', _bhProductController),
              _buildNumberField('Box Width Product', _bwProductController),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveView,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
