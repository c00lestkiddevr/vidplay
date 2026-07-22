import SwiftUI
import AVFoundation

struct FullScreenRawPlayerView: View {
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            // Forces a true black background behind the video
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            if let player = player {
                // Renders the raw video layer with zero controls or touch overlays
                RawVideoPlayerContainer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        player.play()
                    }
            } else {
                Color.black
                    .onAppear {
                        locateAndPlayVideo()
                    }
            }
        }
    }

    func locateAndPlayVideo() {
        // Automatically scans the root app directory shown in your file explorer payload
        guard let resourcePath = Bundle.main.resourcePath,
              let items = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) else { return }
        
        // Target the local .m4v file 
        if let targetVideo = items.first(where: { $0.localizedCaseInsensitiveContains(".m4v") }) {
            let fullURL = URL(fileURLWithPath: resourcePath).appendingPathComponent(targetVideo)
            
            let newPlayer = AVPlayer(url: fullURL)
            // Loops the video infinitely if it reaches the end frame
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: newPlayer.currentItem, queue: .main) { _ in
                newPlayer.seek(to: .zero)
                newPlayer.play()
            }
            
            self.player = newPlayer
        }
    }
}

// SwiftUI Wrapper for UIKit's raw AVPlayerLayer 
struct RawVideoPlayerContainer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let playerLayer = AVPlayerLayer(player: player)
        
        // aspectFill makes the video span across the entire iPhone screen geometry
        playerLayer.videoGravity = .videoGravityResizeAspectFill
        view.layer.addSublayer(playerLayer)
        
        // Store the layer reference to update its size later
        context.coordinator.playerLayer = playerLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Dynamically fits the raw video layout when the device changes orientation
        DispatchQueue.main.async {
            context.coordinator.playerLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}
