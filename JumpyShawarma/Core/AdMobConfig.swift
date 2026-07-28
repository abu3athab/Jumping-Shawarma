import Foundation

enum AdMobConfig {
    /// AdMob → Apps → your app → App settings → App ID (ends with ~…)
    static let applicationID = "ca-app-pub-1040782390047587~1111618294"

    /// AdMob → Ad units → Keep Cooking Continue (ends with /…)
    static let rewardedContinueUnitID = "ca-app-pub-1040782390047587/7584997071"

    /// Google's official test IDs — used in Debug until you paste your real IDs above.
    private static let testApplicationID = "ca-app-pub-3940256099942544~1458002511"
    private static let testRewardedUnitID = "ca-app-pub-3940256099942544/1712485313"

    static var appID: String {
        #if DEBUG
        return testApplicationID
        #else
        return applicationID
        #endif
    }

    static var rewardedAdUnitID: String {
        #if DEBUG
        return testRewardedUnitID
        #else
        return rewardedContinueUnitID
        #endif
    }
}
