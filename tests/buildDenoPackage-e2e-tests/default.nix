{ callPackage }:
{
  buildDenoPackage-e2e-tests =
    (callPackage ./workspaces { }) // (callPackage ./binaries { }) // (callPackage ./external { });
}
