import Foundation
import UIKit

protocol VideoAttachmentDelegate: class {
    func videoAttachment(
        _ videoAttachment: VideoAttachment,
        imageForURL url: URL,
        onSuccess success: @escaping (UIImage) -> (),
        onFailure failure: @escaping () -> ())

    func videoAttachmentPlaceholderImageFor(attachment: VideoAttachment) -> UIImage
}

/// Custom text attachment.
///
open class VideoAttachment: MediaAttachment {

    /// Video poster image to show, while the video is not played.
    ///
    open var posterURL: URL?
    
    /// Creates a new attachment
    ///
    /// - parameter identifier: An unique identifier for the attachment
    ///
    required public init(identifier: String, srcURL: URL? = nil, posterURL: URL? = nil) {
        super.init(identifier: identifier, url: srcURL)
        self.posterURL = posterURL
        self.overlayImage = Assets.playIcon
    }

    /// Required Initializer
    ///
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        if aDecoder.containsValue(forKey: EncodeKeys.posterURL.rawValue) {
            posterURL = aDecoder.decodeObject(forKey: EncodeKeys.posterURL.rawValue) as? URL
        }
    }

    /// Required Initializer
    ///
    required public init(identifier: String, url: URL?) {        
        super.init(identifier: identifier, url: url)
    }

    /// Required Initializer
    ///
    required public init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
    }

    /// An image to display overlaid on top of the media
    ///
    open override var overlayImage: UIImage? {
        set(newValue) {
            super.overlayImage = newValue ?? Assets.playIcon
        }

        get {
            return super.overlayImage
        }
    }

    // MARK: - NSCoder Support

    override open func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        if let posterURL = self.posterURL {
            aCoder.encode(posterURL, forKey: EncodeKeys.posterURL.rawValue)
        }
    }

    fileprivate enum EncodeKeys: String {
        case posterURL
    }


    // MARK: - Origin calculation

    override func imagePositionX(for containerWidth: CGFloat) -> CGFloat {
        let imageWidth = onScreenWidth(for: containerWidth)

        return CGFloat(floor((containerWidth - imageWidth) / 2))
    }

    override func onScreenHeight(for containerWidth: CGFloat) -> CGFloat {
        if let image = image {
            let targetWidth = onScreenWidth(for: containerWidth)
            let scale = targetWidth / image.size.width

            return floor(image.size.height * scale) + appearance.imageInsets.top + appearance.imageInsets.bottom
        } else {
            return 0
        }
    }

    override func onScreenWidth(for containerWidth: CGFloat) -> CGFloat {
        if let image = image {
            return floor(min(image.size.width, containerWidth))
        } else {
            return 0
        }
    }
}


// MARK: - NSCopying
//
extension VideoAttachment {

    override public func copy(with zone: NSZone? = nil) -> Any {
        guard let clone = super.copy() as? VideoAttachment else {
            fatalError()
        }

        clone.posterURL = posterURL

        return clone
    }
}
