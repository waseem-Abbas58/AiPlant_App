/// User choice on the identify failure screen.
enum IdentifyFailAction {
  /// Close and return to the camera / caller.
  back,

  /// Re-run processing with the same photo(s).
  retrySame,

  /// Pick a new photo from gallery and continue.
  pickGallery,
}
