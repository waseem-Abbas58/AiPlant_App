import 'package:get/get.dart';

import '../../../core/helpers/navigation_helper.dart';
import '../../home/model/suggestion_article.dart';
import '../../home/view/home_view.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../suggestions/view/suggestion_detail_view.dart';
import '../model/search_model.dart';

class SearchViewController extends GetxController {
  final query = ''.obs;

  void onQuery(String value) => query.value = value;

  List<SearchHit> get hits {
    final q = query.value.trim().toLowerCase();
    final all = _catalog();
    if (q.isEmpty) return all.take(8).toList();
    return all
        .where(
          (hit) =>
              hit.title.toLowerCase().contains(q) ||
              hit.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  void open(SearchHit hit) {
    NavigationHelper.back();
    Future<void>.delayed(Duration.zero, hit.onOpen);
  }

  List<SearchHit> _catalog() {
    const tools = [
      'Plant Identifier',
      'Disease Identifier',
      'Tree Identifier',
      'Water Meter',
      'Ask Botanist',
      'Mushroom Identifier',
      'Weed Identifier',
      'Toxicity Identifier',
      'Plant Finder',
      'Plant Statistics',
    ];
    final items = <SearchHit>[
      for (final title in tools)
        SearchHit(
          title: title,
          subtitle: 'Tool',
          onOpen: HomeView.onPlantToolTap(title) ?? () {},
        ),
      for (final article in SuggestionArticle.samples)
        SearchHit(
          title: article.title,
          subtitle: article.category,
          onOpen: () => NavigationHelper.to(
            () => SuggestionDetailView(article: article),
          ),
        ),
    ];
    if (Get.isRegistered<MyGardenController>()) {
      final garden = Get.find<MyGardenController>();
      for (final plant in garden.plants) {
        items.add(
          SearchHit(
            title: plant.name,
            subtitle: plant.displayScientific.isEmpty
                ? 'My Garden'
                : plant.displayScientific,
            onOpen: () => garden.openPlantDetail(plant),
          ),
        );
      }
    }
    return items;
  }
}
