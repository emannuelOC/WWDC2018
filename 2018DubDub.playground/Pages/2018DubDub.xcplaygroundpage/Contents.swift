import UIKit
import AVFoundation
import Vision
import PlaygroundSupport

public protocol FrameExtractorDelegate: class {
    func captured(image: CIImage)
}

public class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    
    public weak var delegate: FrameExtractorDelegate?
    
    override public init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: AVSession configuration
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = .medium
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "capture"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: .video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = true
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.devices().filter {
            $0.hasMediaType(.video) &&
                $0.position == .front
            }.first
    }
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        return ciImage
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let ciImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.captured(image: ciImage)
        }
    }
}

class Mannel {
    
    class HeadView: UIView {
        
        let skinColor = UIColor(red: 254/255.0, green: 212/255.0, blue: 176/255.0, alpha: 1)
        
        let skinColor2 = UIColor(red: 230/255.0, green: 180/255.0, blue: 153/255.0, alpha: 1)
        
        let hairColor = UIColor(red: 100/255.0, green: 52/255.0, blue: 22/255.0, alpha: 1)
        
        let mouthColor = UIColor(red: 170/255.0, green: 67/255.0, blue: 52/255.0, alpha: 1)
        
        var tongueColor = UIColor(red: 230/255.0, green: 71/255.0, blue: 94/255.0, alpha: 1)
        
        var eyeColor = UIColor(red: 184/255.0, green: 154/255.0, blue: 129/255.0, alpha: 1)
        
        var sizeConstraints = [NSLayoutConstraint]()
        
        var eyeSize = CGFloat(1) {
            didSet {
                for c in sizeConstraints {
                    c.constant = max(eyeSize*300, 5)
                }
                setNeedsLayout()
            }
        }
        
        lazy var rightEyeView: UIView = {
            let view = UIView()
            view.backgroundColor = eyeColor
            view.layer.cornerRadius = 5.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        lazy var leftEyeView: UIView = {
            let view = UIView()
            view.backgroundColor = eyeColor
            view.layer.cornerRadius = 5.5
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        func setupConstraints() {
            addSubview(rightEyeView)
            addSubview(leftEyeView)
            rightEyeView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -25).isActive = true
            rightEyeView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8).isActive = true
            sizeConstraints.append(rightEyeView.heightAnchor.constraint(equalToConstant: 11))//.isActive = true
            rightEyeView.widthAnchor.constraint(equalToConstant: 11).isActive = true
            leftEyeView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 25).isActive = true
            leftEyeView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 8).isActive = true
            sizeConstraints.append(leftEyeView.heightAnchor.constraint(equalToConstant: 11))//.isActive = true
            leftEyeView.widthAnchor.constraint(equalToConstant: 11).isActive = true
            for c in sizeConstraints {
                c.isActive = true
            }
        }
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 131, height: 168))
            setupLayers()
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupLayers() {
            let layers = [
                rightEar,
                leftEar,
                face,
                hair,
                front,
                nose,
                mouth
            ]
            for l in layers {
                layer.addSublayer(l)
            }
        }
        
        lazy var face: CALayer = {
            let face = CALayer()
            face.frame = CGRect(x: 13, y: 27, width: 105, height: 141)
            face.cornerRadius = 52.5
            face.backgroundColor = skinColor.cgColor
            
            return face
        }()
        
        lazy var front: CALayer = {
            let front = CALayer()
            front.frame = CGRect(x: 16, y: 42, width: 98, height: 59)
            front.cornerRadius = 13
            front.backgroundColor = skinColor.cgColor
            
            return front
        }()
        
        lazy var hair: CALayer = {
            let hair = CALayer()
            hair.frame = CGRect(x: 0, y: 0, width: 131, height: 82)
            
            let curls = [
                (1, 42),
                (0, 23),
                (17, 10),
                (49, 23),
                (34, 10),
                (50, 0),
                (67, 10),
                (82, 10),
                (96, 29),
                (97, 48)
            ]
            
            for curl in curls {
                let curlLayer = CALayer()
                curlLayer.frame = CGRect(x: curl.0, y: curl.1, width: 34, height: 34)
                curlLayer.backgroundColor = hairColor.cgColor
                curlLayer.cornerRadius = 17
                hair.addSublayer(curlLayer)
            }
            
            return hair
        }()
        
        lazy var rightEar: CALayer = {
            let ear = CALayer()
            ear.frame = CGRect(x: 1, y: 84, width: 22, height: 22)
            ear.cornerRadius = 11
            ear.backgroundColor = skinColor2.cgColor
            return ear
        }()
        
        lazy var leftEar: CALayer = {
            let ear = CALayer()
            ear.frame = CGRect(x: 107, y: 84, width: 22, height: 22)
            ear.cornerRadius = 11
            ear.backgroundColor = skinColor2.cgColor
            return ear
        }()
        
        lazy var nose: CALayer = {
            let nose = CALayer()
            nose.frame = CGRect(x: 57, y: 82, width: 17, height: 31)
            nose.cornerRadius = 8.5
            nose.backgroundColor = skinColor2.cgColor
            return nose
        }()
        
        lazy var mouth: CALayer = {
            let mouth = CAShapeLayer()
            mouth.frame = CGRect(x: 35, y: 119, width: 61, height: 31)
            let mouthPath = UIBezierPath()
            mouthPath.move(to: CGPoint(x: 0, y: 0))
            mouthPath.addArc(withCenter: CGPoint(x: 30.5, y: 0), radius: 31, startAngle: 0, endAngle: CGFloat(Double.pi), clockwise: true)
            mouthPath.close()
            mouth.path = mouthPath.cgPath
            mouth.fillColor = mouthColor.cgColor
            
            let teeth = CAShapeLayer()
            teeth.frame = CGRect(x: 0, y: 0, width: 61, height: 11)
            let teethPath = UIBezierPath()
            teethPath.move(to: .zero)
            teethPath.addArc(withCenter: CGPoint(x: 30.5, y: 0), radius: 31, startAngle: 0, endAngle: CGFloat(Double.pi / 8), clockwise: true)
            teethPath.addLine(to: CGPoint(x: 2, y: 11))
            teethPath.addArc(withCenter: CGPoint(x: 30.5, y: 0), radius: 31, startAngle: CGFloat(Double.pi - Double.pi / 8), endAngle: CGFloat(Double.pi), clockwise: true)
            teethPath.close()
            teeth.fillColor = UIColor.white.cgColor
            teeth.path = teethPath.cgPath
            mouth.addSublayer(teeth)
            
            let tongue = CAShapeLayer()
            tongue.frame = CGRect(x: 15, y: 17, width: 32, height: 13)
            let tonguePath = UIBezierPath()
            tonguePath.move(to: CGPoint(x: 32, y: 7))
            tonguePath.addArc(withCenter: CGPoint(x: 16, y: -18), radius: 31, startAngle: CGFloat(Double.pi / 3.5), endAngle: CGFloat(Double.pi - Double.pi / 3.5), clockwise: true)
            
            tonguePath.addArc(withCenter: CGPoint(x: 16, y: 40), radius: 41, startAngle: CGFloat(Double.pi * 1.33), endAngle: CGFloat(Double.pi * 1.67), clockwise: true)
            tonguePath.addLine(to: CGPoint(x: 32, y: 7))
            tonguePath.close()
            tongue.fillColor = tongueColor.cgColor
            tongue.path = tonguePath.cgPath
            
            mouth.addSublayer(tongue)
            
            //        mouth.masksToBounds = true
            return mouth
        }()
        
    }
    
    class BodyView: UIView {
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 155, height: 271))
            setupLayers()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupLayers() {
            let layers = [
                coatLayer,
                tShirtLayer,
                neckLayer
            ]
            for l in layers {
                layer.addSublayer(l)
            }
        }
        
        let coatColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        let tShirtColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let skinColor2 = UIColor(red: 230/255.0, green: 180/255.0, blue: 153/255.0, alpha: 1)
        
        lazy var coatLayer: CALayer = {
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: 47, width: 155, height: 225)
            layer.cornerRadius = 77.5
            layer.backgroundColor = coatColor.cgColor
            return layer
        }()
        
        lazy var tShirtLayer: CALayer = {
            let layer = CALayer()
            layer.frame = CGRect(x: 60, y: 10, width: 36, height: 210)
            layer.cornerRadius = 18
            layer.backgroundColor = tShirtColor.cgColor
            return layer
        }()
        
        lazy var neckLayer: CALayer = {
            let layer = CALayer()
            layer.frame = CGRect(x: 60, y: 10, width: 36, height: 71)
            layer.cornerRadius = 18
            layer.backgroundColor = skinColor2.cgColor
            return layer
        }()
        
    }
    
    class HelmetView: UIView {
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 222, height: 248))
            setupLayers()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupLayers() {
            let layers = [
                helmetLayer,
                neckLayer
            ]
            for l in layers {
                layer.addSublayer(l)
            }
        }
        
        let helmetColor = #colorLiteral(red: 0.7303532958, green: 0.7994551659, blue: 0.9560970664, alpha: 0.4685359597)
        
        lazy var helmetLayer: CALayer = {
            let layer = RadialGradientLayer(center: CGPoint(x: 111, y: 111), radius: 111, colors: [
                UIColor.clear.cgColor,
                helmetColor.cgColor,
                ])
            layer.frame = CGRect(x: 0, y: 0, width: 222, height: 222)
            layer.cornerRadius = 111
            layer.setNeedsDisplay()
            return layer
        }()
        
        lazy var neckLayer: CALayer = {
            let layer = CALayer()
            layer.frame = CGRect(x: 48, y: 216, width: 126, height: 32)
            layer.cornerRadius = 16
            layer.backgroundColor = helmetColor.cgColor
            return layer
        }()
        
        
    }
    
    class View: UIView {
        
        var distance: CGFloat = 1 {
            didSet {
                head.eyeSize = distance
            }
        }
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 222, height: 433))
            setupSubviews()
            setupFrames()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let head = HeadView()
        let body = BodyView()
        let helmet = HelmetView()
        
        func setupSubviews() {
            addSubview(body)
            addSubview(head)
            addSubview(helmet)
        }
        
        func setupFrames() {
            head.frame = CGRect(x: 45, y: 46, width: head.frame.width, height: head.frame.height)
            body.frame = CGRect(x: 33, y: 162, width: body.frame.width, height: body.frame.height)
        }
        
        
        
    }
    
}

class RadialGradientLayer: CALayer {
    
    override init(){
        
        super.init()
        
        needsDisplayOnBoundsChange = true
    }
    
    init(center: CGPoint, radius: CGFloat, colors: [CGColor]){
        
        self.center = center
        self.radius = radius
        self.colors = colors
        
        super.init()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init()
        
    }
    
    var center:CGPoint = CGPoint(x: 50, y: 50)
    var radius:CGFloat = 20
    var colors = [
        UIColor(red: 251/255, green: 237/255, blue: 33/255, alpha: 1.0).cgColor,
        UIColor(red: 251/255, green: 179/255, blue: 108/255, alpha: 1.0).cgColor
    ]
    
    override func draw(in ctx: CGContext) {
        
        ctx.saveGState()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: locations)!
        
        ctx.drawRadialGradient(gradient,
                               startCenter: center,
                               startRadius: 0.0,
                               endCenter: center,
                               endRadius: radius,
                               options: [])
        
    }
    
}

class SpaceView: UIView {
    
    let stars = [
        (12, 0.7, 0.1),
        (25, 0.8, 0.2),
        (12, 0.6, 0.29),
        (12, 0.55, 0.32),
        (25, 0.25, 0.4),
        (46, 0.6, 0.6),
        (25, 0.8, 0.65),
        (12, 0.15, 0.7),
        (25, 0.25, 0.8),
        (12, 0.8, 0.85)
    ]
    
    var skyLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSky()
        //setupStars()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var first = true
    
    func setupStars() {
        if !first { return }
        first = false
        for s in stars {
            let star = CALayer()
            star.frame = CGRect(x: frame.width * CGFloat(s.1),
                                y: frame.height * CGFloat(s.2),
                                width: CGFloat(s.0) / 2.0,
                                height: CGFloat(s.0) / 2.0)
            star.backgroundColor = #colorLiteral(red: 0.9250472188, green: 0.7974560857, blue: 0.9364998937, alpha: 1).cgColor
            star.cornerRadius = CGFloat(s.0) / 4.0
            
            star.shadowColor = UIColor.white.cgColor
            star.shadowOffset = CGSize(width: 0, height: 5)
            star.shadowRadius = 12
            star.shadowOpacity = 0.5
            
            layer.insertSublayer(star, at: 1)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        skyLayer?.frame = bounds
        //setupStars()
    }
    
    func setupSky() {
        let skyLayer = CAGradientLayer()
        skyLayer.frame = bounds
        skyLayer.colors = [#colorLiteral(red: 0.1644538343, green: 0.17376405, blue: 0.254699409, alpha: 1), #colorLiteral(red: 0.3250321746, green: 0.2411090732, blue: 0.4993002415, alpha: 1)].map { $0.cgColor }
        layer.addSublayer(skyLayer)
        self.skyLayer = skyLayer
    }
    
}

//: Playground - noun: a place where people can play

class VisionViewController: UIViewController, FrameExtractorDelegate {
    
    let stars = [
        (12, 0.7, 0.1),
        (25, 0.8, 0.2),
        (12, 0.6, 0.29),
        (12, 0.55, 0.32),
        (25, 0.25, 0.4),
        (46, 0.6, 0.6),
        (25, 0.8, 0.65),
        (12, 0.15, 0.7),
        (25, 0.25, 0.8),
        (12, 0.8, 0.85)
    ]
    
    func setupStars() {
        for s in stars {
            let star = CALayer()
            star.frame = CGRect(x: view.frame.width * CGFloat(s.1),
                                y: view.frame.height * CGFloat(s.2),
                                width: CGFloat(s.0) / 2.0,
                                height: CGFloat(s.0) / 2.0)
            star.backgroundColor = #colorLiteral(red: 0.9250472188, green: 0.7974560857, blue: 0.9364998937, alpha: 1).cgColor
            star.cornerRadius = CGFloat(s.0) / 4.0
            
            star.shadowColor = UIColor.white.cgColor
            star.shadowOffset = CGSize(width: 0, height: 5)
            star.shadowRadius = 12
            star.shadowOpacity = 0.5
            
            view.layer.insertSublayer(star, at: 1)
        }
    }
    
    override func loadView() {
        let view = SpaceView()
        self.view = view
    }
    
    var extractor: FrameExtractor?
    
    var info = [
        ("Hi! I'm Emannuel. I love iOS Development and Machine Learning", "Next"),
        ("""
In this playground, I'll show you how
Machine Learning can make the world a little better.
""", "Next"),
        ("""
For many people with motor disabilities, moving around or expressing themselves 
can be very challenging. ML can help with that! With Computer Vision, they can use
facial gestures to move around or express themselves.
""", "Next"),
        ("""
Your goal in this playground is to catch as many space apples as you can. 
In order to move around all you nedd to do is incline your head a little.
I will look at your eyes to know where you wanna move.
""", "Next"),
        ("""
Let's check it out!
""", "Start game!")
    ]
    
    func startGame() {
        setupStars()
        resetExtractor()
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            if self.apple != nil { return }
            let l = self.appleLabel()
            self.apple = l
            self.view.addSubview(l)
        })
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.21, repeats: true, block: { (_) in
            self.updatePosition()
        })
    }
    
    var infoIndex = 0
    
    var infoConstraintX: NSLayoutConstraint?
    var infoConstraintY: NSLayoutConstraint?
    
    func updateInfo() {
        if infoIndex >= info.count { return }
        let i = info[infoIndex]
        infoView.text = i.0
        infoView.nextButtonTitle = i.1
        if infoIndex == info.count - 1 {
            infoView.onNextButtonTapped = {
                self.infoConstraintX?.constant = -300
                self.infoConstraintY?.constant = -450
                self.infoView.toggle()
                UIView.animate(withDuration: 0.7, animations: {
                    self.view.setNeedsLayout()
                    self.infoView.layer.cornerRadius = 200
                }, completion: { _ in 
                    self.startGame()
                })
            } 
        } else {
            infoIndex += 1
            infoView.onNextButtonTapped = {
                self.updateInfo()
            }
        }
        infoView.setNeedsLayout()
        infoView.setNeedsDisplay()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(ballView)
        ballView.translatesAutoresizingMaskIntoConstraints = false
        ballView.heightAnchor.constraint(equalToConstant: 433).isActive = true
        ballView.widthAnchor.constraint(equalToConstant: 222).isActive = true
        ballView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 150).isActive = true
        xConstraint = ballView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        xConstraint?.isActive = true
        
        view.addSubview(scoreLabel)
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 300).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        view.addSubview(infoView)
        infoView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        infoView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        infoConstraintX = infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100)
        infoConstraintY = infoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120)
        
        infoConstraintX?.isActive = true
        infoConstraintY?.isActive = true
        updateInfo()

    }
    
    
    @objc func resetExtractor() {
        extractor = FrameExtractor()
        extractor?.delegate = self
    }
    
    var apple: UILabel?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score) space apples"
            if score >= 20 {
                scoreLabel.text = "\(score) apples!! That's enough, isn't it?"
            }
        }
    }
    
    lazy var infoView: InfoView = {
        let view = InfoView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func appleLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: CGFloat(arc4random() % UInt32(view.frame.width + 1)), y: view.frame.height - 150, width: 100, height: 50))
        label.font = UIFont.systemFont(ofSize: 50)
        label.text = "🍎"
        return label
    }
    
    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var xConstraint: NSLayoutConstraint?
    
    lazy var ballView: Mannel.View = {
        let view = Mannel.View()
        return view
    }()
    
    func updatePosition() {
        xConstraint?.constant -= slope * 100
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.setNeedsLayout()
        }, completion: { finished in
            if !finished { return }
            if self.apple?.frame.intersects(self.ballView.frame) ?? false {
                self.apple?.removeFromSuperview()
                self.apple = nil
                self.score += 1
            }
        })
    }
    
    var distance: CGFloat = 0 {
        didSet {
            ballView.distance = distance
        }
    }
    
    var slope: CGFloat = 0 
    
    var control = 0
    
    func captured(image: CIImage) {
        control += 1
        if control % 5 != 0 { return }
        let faceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            for r in request.results ?? [] {
                if let observation = r as? VNFaceObservation {
                    
                    guard let leftAvg = observation.landmarks?.leftEye?.normalizedPoints.first,
                        let rightAvg = observation.landmarks?.rightEye?.normalizedPoints.first else {
                            continue
                    }
                    
                    if let le1 = observation.landmarks?.leftEye?.normalizedPoints[5].y,
                    let le2 = observation.landmarks?.leftEye?.normalizedPoints[2].y,
                    let re1 = observation.landmarks?.rightEye?.normalizedPoints[5].y,
                    let re2 = observation.landmarks?.leftEye?.normalizedPoints[2].y {
                        self.distance = (le2+re2)-(le1+le2)
                    }
                    
                    let slope = (rightAvg.y - leftAvg.y)/(rightAvg.x - leftAvg.x)
                    self.slope = slope
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        do {
            try handler.perform([faceRequest])
        } catch {
            print(error)
        }
    }
    
}

class InfoView: UIView {
    
    lazy var textLabel: UILabel = {
        let l = UILabel()
        l.textColor = #colorLiteral(red: 0.062745101749897, green: 0.0, blue: 0.192156866192818, alpha: 1.0)
        l.font = UIFont.boldSystemFont(ofSize: 24)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    lazy var nextButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return b
    }()
    
    var text: String? {
        didSet { textLabel.text = text }
    }
    
    var nextButtonTitle: String? {
        didSet { nextButton.setTitle(nextButtonTitle, for: .normal) }
    }
    
    var onNextButtonTapped: (() -> Void)?
    
    @objc func nextButtonTapped() {
        onNextButtonTapped?()
    }
    
    func setupConstraints() {
        addSubview(textLabel)
        addSubview(nextButton)
        textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        textLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        nextButton.topAnchor.constraint(greaterThanOrEqualTo: textLabel.bottomAnchor, constant: 20).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 0.392, green: 0.930, blue: 0.99, alpha: 1)
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggle() {
        if textLabel.isHidden {
            textLabel.isHidden = false
            nextButton.isHidden = false
        } else {
            textLabel.isHidden = true
            nextButton.isHidden = true
        }
    }
    
}


extension CGPoint: Point {}

func +(lhs: Point, rhs: Point) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: Point, rhs: Point) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func *(lhs: Point, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
}

func *(lhs: Point, rhs: CGSize) -> CGPoint {
    return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
}

protocol Point {
    var x: CGFloat { get }
    var y: CGFloat { get }
}


let vc = VisionViewController()


PlaygroundPage.current.liveView = vc






