#import <Foundation/Foundation.h>

#import "FIRDynamicLink.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @file FIRDynamicLinks.h
 * @abstract Firebase Dynamic Links
 */

/**
 * @abstract The definition of the block used by |resolveShortLink:completion:|
 */
typedef void (^FIRDynamicLinkResolverHandler)(NSURL * _Nullable url, NSError * _Nullable error);

/**
 * @abstract The definition of the block used by |handleUniversalLink:completion:|
 */
typedef void (^FIRDynamicLinkUniversalLinkHandler)(FIRDynamicLink * _Nullable dynamicLink,
                                                   NSError * _Nullable error);

/**
 * @class FIRDynamicLinks
 * @abstract A class that checks for pending Dynamic Links and parses URLs.
 */
@interface FIRDynamicLinks : NSObject

/**
 * @method sharedInstance
 * @abstract Shared instance of FIRDynamicLinks. Returns nil on iOS versions prior to 8.
 * @return Shared instance of FIRDynamicLinks.
 */
+ (nullable instancetype)dynamicLinks NS_SWIFT_NAME(dynamicLinks());

/**
 * @method shouldHandleDynamicLinkFromCustomSchemeURL:
 * @abstract Determine whether FIRDynamicLinks should handle the given URL. This does not
 *     guarantee that |dynamicLinkFromCustomSchemeURL:| will return a non-nil value, but it means
 *     the client should not attempt to handle the url.
 * @param url custom scheme url.
 * @return whether it can be handled by GINDurableDeepLinkService.
 */
- (BOOL)shouldHandleDynamicLinkFromCustomSchemeURL:(NSURL *)url;

/**
 * @method dynamicLinkFromCustomSchemeURL:
 * @abstract Get a Dynamic Link from a custom scheme URL. This method could parse URLs with custom
 *     scheme, for instance, "comgoogleapp://google/link?deep_link_id=abc123". It is suggested to
 *     call it inside your |UIApplicationDelegate|'s
 *     |application:openURL:sourceApplication:annotation| and|application:openURL:options:|.
 * @param url custom scheme url.
 * @return Dynamic Link object if url is valid and has link parameter, or nil.
 */
- (nullable FIRDynamicLink *)dynamicLinkFromCustomSchemeURL:(NSURL *)url;

/**
 * @method dynamicLinkFromUniversalLinkURL:
 * @abstract Get a Dynamic Link from a universal link URL. This method could parse universal link
 *     URLs, for instance,
 *     "https://example.app.goo.gl?link=https://www.google.com&ibi=com.google.app&ius=comgoogleapp".
 *     It is suggested to call it inside your |UIApplicationDelegate|'s
 *     |application:continueUserActivity:restorationHandler:|.
 * @param url Custom scheme url.
 * @return Dynamic Link object if url is valid and has link parameter, or nil.
 */
- (nullable FIRDynamicLink *)dynamicLinkFromUniversalLinkURL:(NSURL *)url;

/**
 * @method handleUniversalLink:completion:
 * @abstract Convenience method to handle a Universal Link whether it is long or short. A long link
 *     will call the handler immediately, but a short link may not.
 * @param universalLinkURL A Universal Link URL.
 * @param completion A block that handles the outcome of attempting to create a FIRDynamicLink.
 * @return YES if the SDK is handling the link, otherwise, NO.
 */
- (BOOL)handleUniversalLink:(NSURL *)url
                 completion:(FIRDynamicLinkUniversalLinkHandler)completion;

/**
 * @method resolveShortLink:completion:linkResolver:
 * @abstract Retrieves the details of the Dynamic Link that the shortened URL represents
 * @param url A Short Dynamic Link.
 * @param completion Block to be run upon completion.
 */
- (void)resolveShortLink:(NSURL *)url
              completion:(FIRDynamicLinkResolverHandler)completion;

/**
 * @method matchesShortLinkFormat:
 * @abstract Determines if a given URL matches the given short Dynamic Link format.
 * @param url A URL.
 * @return YES if the URL is a short Dynamic Link, otherwise, NO.
 */
- (BOOL)matchesShortLinkFormat:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
