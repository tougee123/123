//
//  ViewController.swift
//  CmdCode
//
//  Created by wangpo on 2026/2/22.
//


/*
 帮我设计代码，横屏
 左侧区域 UIImageView 248 * 320 红色，水平左对齐，垂直居中对齐； 
 右侧区域 UIImageView 320 * 320 蓝色，水平右对齐，垂直居中对齐；
 右侧通过Kingfisher加载本地gif，“补给背包SASWWS-表情版.gif” 只播放一遍

 左侧增加指令视图，UIView，水平左对齐，垂直居中对齐；50 * 300，
 指令视图内部有6个imageview，宽度为50，高度为50，之间无间距；
 图片为SF arrow.left arrow.right arrow.up arrow.down 

 右下角创建操作面板视图  300 *200 水平右对齐，垂直居中对齐；
 面板视图由4个按钮组成，按钮大小100*100，底部 3个 顶部一个。
 */
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

class ViewController: UIViewController, AnimatedImageViewDelegate {

    private var userInput: String = ""
    private var audioPlayer: AVAudioPlayer?

    private lazy var instructionView: UIView = {
        let v = UIView()
        return v
    }()
    
    /// W=上 S=下 A=左 D=右 对应面板图 up / down / left / right
    private let wsadToImageName: [Character: String] = [
        "W": "up_",
        "S": "down_",
        "A": "left_",
        "D": "right_"
    ]
    private var arrowImageViews: [UIImageView] = []
    
    private lazy var leftImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "leftLogo")
        return iv
    }()
    
    private lazy var leftFileNameLabel: UILabel = {
        let iv = UILabel()
        iv.backgroundColor = .black
        iv.textColor = .yellow
        iv.textAlignment = .center
        iv.text = ""
        iv.font = .systemFont(ofSize: 30, weight: .medium)
        return iv
    }()
    
    private lazy var leftFreeLabel: UILabel = {
        let iv = UILabel()
        iv.backgroundColor = .black
        iv.textColor = .yellow
        iv.textAlignment = .center
        iv.text = "已释放"
        iv.font = .systemFont(ofSize: 30, weight: .medium)
        return iv
    }()
    
    private lazy var containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    private lazy var operationPanelView: UIView = {
        let v = UIView()
        return v
    }()

    private lazy var rightImageView: AnimatedImageView = {
        let iv = AnimatedImageView()
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.repeatCount = .once
        iv.delegate = self
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startRound()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 568, height: 320))
            make.center.equalToSuperview()
        }

        containerView.addSubview(leftImageView)
        containerView.addSubview(leftFileNameLabel)
        containerView.addSubview(leftFreeLabel)
        
        containerView.addSubview(instructionView)
        containerView.addSubview(rightImageView)
        containerView.addSubview(operationPanelView)

        leftImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 248, height: 131))
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        leftImageView.isHidden = true
        
        leftFileNameLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 248, height: 40))
            make.left.equalToSuperview()
            make.top.equalTo(leftImageView.snp.bottom).offset(30)
        }
        leftFileNameLabel.isHidden = true
        
        leftFreeLabel.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 248, height: 40))
            make.left.equalToSuperview()
            make.top.equalTo(leftFileNameLabel.snp.bottom).offset(20)
        }
        leftFreeLabel.isHidden = true
        
        
        
        
        instructionView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 280))
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        let cellSize: CGFloat = 40
        let spacing: CGFloat = 20
        for i in 0..<10 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFit  // 填满 50x50，图片会放大显示
            iv.clipsToBounds = true
            iv.tintColor = .white
            instructionView.addSubview(iv)
            arrowImageViews.append(iv)
            
            let col = i / 5
            let row = i % 5
            iv.snp.makeConstraints { make in
                make.width.height.equalTo(cellSize)
                make.left.equalToSuperview().offset(CGFloat(col) * (cellSize + spacing))
                make.top.equalToSuperview().offset(CGFloat(row) * (cellSize + spacing))
            }
        }
        
        
        
        rightImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 320, height: 320))
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        rightImageView.isHidden = true


        operationPanelView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 250, height: 150))
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        let topButton = createPanelButton(symbolName: "up", wsadChar: "W")
        let bottomLeftButton = createPanelButton(symbolName: "left", wsadChar: "A")
        let bottomCenterButton = createPanelButton(symbolName: "down", wsadChar: "S")
        let bottomRightButton = createPanelButton(symbolName: "right", wsadChar: "D")

        operationPanelView.addSubview(topButton)
        operationPanelView.addSubview(bottomLeftButton)
        operationPanelView.addSubview(bottomCenterButton)
        operationPanelView.addSubview(bottomRightButton)

        topButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 50))
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        bottomLeftButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 100))
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(25)
        }
        bottomCenterButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 100))
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        bottomRightButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 50, height: 100))
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-25)
        }
    }

    private func createPanelButton(symbolName: String, wsadChar: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .black
        btn.tintColor = .white
        btn.setImage(UIImage(named: symbolName), for: .normal)
        
        btn.tag = Int(Character(wsadChar).asciiValue ?? 0)
        btn.addTarget(self, action: #selector(panelButtonTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func panelButtonTapped(_ sender: UIButton) {
        playSound("tone")
        let char = Character(UnicodeScalar(sender.tag)!)
        userInput.append(char)

        // 左侧 instructionView：用 up / down / left / right 图，超过 10 个从第一个继续覆盖
        if let symbolName = wsadToImageName[char], !arrowImageViews.isEmpty {
            let index = (userInput.count - 1) % arrowImageViews.count
            let iv = arrowImageViews[index]
            iv.image = UIImage(named: symbolName)
            iv.isHidden = false
        }

        // 如果当前输入字符串包含任何一个指令，触发动画
        let upperInput = userInput.uppercased()
        for key in CMDManager.shared.gifMapping.keys {
            let upperKey = key.uppercased()
            if upperInput.contains(upperKey) {
                playSound("success")
                print("match:", upperKey)
                onMatch(with: upperKey)
                userInput = ""
                break
            }
        }
    }

    private func playSound(_ name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {}
    }
    
    
    private func startRound() {
        userInput = ""

        instructionView.isHidden = false
        operationPanelView.isHidden = false

        leftImageView.isHidden = true
        leftFileNameLabel.isHidden = true
        leftFreeLabel.isHidden = true

        rightImageView.isHidden = true

        for iv in arrowImageViews {
            iv.isHidden = true
        }
    }

    private func onMatch(with key: String) {
        rightImageView.isHidden = false
        leftImageView.isHidden = false
        leftFileNameLabel.isHidden = false
        leftFreeLabel.isHidden = false

        operationPanelView.isHidden = true
        instructionView.isHidden = true

        let upperKey = key.uppercased()
        guard let filename = CMDManager.shared.gifMapping[upperKey] else { return }
        let baseName = (filename as NSString).deletingPathExtension
        guard let gifURL = Bundle.main.url(forResource: baseName, withExtension: "gif") else { return }
        rightImageView.kf.setImage(with: gifURL)

        guard let namePrefix = CMDManager.shared.namePrefixMapping[upperKey] else { return }
        leftFileNameLabel.text = namePrefix
    }

    func animatedImageViewDidFinishAnimating(_ imageView: AnimatedImageView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startRound()
        }
    }
    
}
        
       
