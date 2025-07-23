import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manageorders/providers/shop_details_provider.dart';
import 'package:manageorders/widgets/time_display_widget.dart';

class ShopDetailsScreen extends ConsumerStatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _controllers = List.generate(7, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final details = await ref.read(shopDetailsProvider.future);
      if (details != null) {
        _controllers[0].text = details.shopName;
        _controllers[1].text = details.address1;
        _controllers[2].text = details.address2;
        _controllers[3].text = details.address3;
        _controllers[4].text = details.address4;
        _controllers[5].text = details.postcode;
        _controllers[6].text = details.phone;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = [
      'Shop Name',
      'Address Line 1',
      'Address Line 2',
      'Address Line 3',
      'Address Line 4',
      'Postcode',
      'Phone Number',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Shop Details'),
      actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TimeDisplayWidget(),
          ),
        ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: TextFormField(
                      controller: _controllers[i],
                      decoration: InputDecoration(labelText: labels[i]),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllers[6],
                decoration: InputDecoration(labelText: labels[6]),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await ref
                        .read(shopDetailsProvider.notifier)
                        .saveShopDetails(
                          shopName: _controllers[0].text,
                          address1: _controllers[1].text,
                          address2: _controllers[2].text,
                          address3: _controllers[3].text,
                          address4: _controllers[4].text,
                          postcode: _controllers[5].text,
                          phone: _controllers[6].text,
                        );
                    if (!mounted) return;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved successfully')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
