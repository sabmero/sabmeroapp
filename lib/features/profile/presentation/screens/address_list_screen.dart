import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabmeroapp/features/profile/data/repositories/profile_repository_impl.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/profile_provider.dart';
import '../widgets/address_card.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesState = ref.watch(addressesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: addressesState.when(
        data: (addresses) => addresses.isEmpty
            ? const Center(child: Text('No addresses saved yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                itemBuilder: (context, i) => AddressCard(
                  address: addresses[i],
                  onDelete: () => ref
                      .read(profileRepositoryProvider)
                      .deleteAddress(addresses[i].id)
                      .then((_) => ref.invalidate(addressesProvider)),
                ),
              ),
        loading: () => const CardListSkeleton(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(addressesProvider),
        ),
      ),
    );
  }
}
