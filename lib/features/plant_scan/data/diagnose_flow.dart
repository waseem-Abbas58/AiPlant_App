import '../../../core/helpers/navigation_helper.dart';
import '../view/diagnose_capture_view.dart';
import '../view/diagnose_symptom_view.dart';
import '../view/identify_disease_view.dart';

/// Symptom-first diagnose flow — does not reuse the identify photo.
class DiagnoseFlow {
  DiagnoseFlow._();

  static Future<void> start({required String plantName}) async {
    final symptom = await NavigationHelper.to<String>(
      () => DiagnoseSymptomView(plantName: plantName),
    );
    if (symptom == null || symptom.isEmpty) return;

    final photos = await NavigationHelper.to<List<String>>(
      () => DiagnoseCaptureView(
        plantName: plantName,
        symptomId: symptom,
      ),
    );
    if (photos == null || photos.isEmpty) return;

    await NavigationHelper.to<void>(
      () => IdentifyDiseaseView(
        imagePaths: photos,
        plantName: plantName,
        symptomId: symptom,
      ),
    );
  }
}
