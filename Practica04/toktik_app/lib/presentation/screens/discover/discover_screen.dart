import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik_app/presentation/providers/discover_provider.dart';
import 'package:toktik_app/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final discoverProvider = context.watch<DiscoverProvider>();


    return Scaffold(
      body: discoverProvider.initialLoading
        ? const Center( child: CircularProgressIndicator( strokeWidth: 2 ) )
        : discoverProvider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(discoverProvider.errorMessage!, textAlign: TextAlign.center),
              ),
            )
          : VideoScrollableView(videos: discoverProvider.videos )
    );
  }
}
