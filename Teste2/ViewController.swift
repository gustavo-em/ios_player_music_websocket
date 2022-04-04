//
//  ViewController.swift
//  Teste2
//
//  Created by Gustavo Emanuel Farias Rosa on 01/04/22.
//

import UIKit
import AVFoundation
import Starscream

class ViewController: UIViewController, WebSocketDelegate {

    @IBOutlet var viPrincipal: UIView!
    
    @IBOutlet weak var btPlay: UIButton!
    var audioSession = AVAudioSession.sharedInstance()
    var player: AVAudioPlayer!
    
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viPrincipal.backgroundColor = .blue
        initAudioSession()
        connectWB()
        
    }
    
    @IBAction func goPlay(_ sender: Any) {
        playSound()
        var _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            return self.socket.write(string: "hello")
        }
    }
       
    func connectWB(){
        var request = URLRequest(url: URL(string: "ws://192.168.15.90:6969")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        socket.write(string: "Hi Server!")
        socket.onEvent = { event in
                print(event)
        }
    }
    
    func initAudioSession(){
        do{
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setActive(true)
            
        }catch{
            print(error)
        }
    }
    
    func playSound(){
        let path = Bundle.main.path(forResource: "music", ofType : "mp3")!
        let url = URL(fileURLWithPath : path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        }
        catch {
            print (error)
        }
    }
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
       switch event {
       case .connected(let headers):
           isConnected = true
           print("websocket is connected: \(headers)")
       case .disconnected(let reason, let code):
           isConnected = false
           print("websocket is disconnected: \(reason) with code: \(code)")
       case .text(let string):
           print("Received text: \(string)")
       case .binary(let data):
           print("Received data: \(data.count)")
       case .ping(_):
           break
       case .pong(_):
           break
       case .viabilityChanged(_):
           break
       case .reconnectSuggested(_):
           break
       case .cancelled:
           isConnected = false
       case .error(let error):
           isConnected = false
           handleError(error)
       }
   }
   
   func handleError(_ error: Error?) {
       if let e = error as? WSError {
           print("websocket encountered an error: \(e.message)")
       } else if let e = error {
           print("websocket encountered an error: \(e.localizedDescription)")
       } else {
           print("websocket encountered an error")
       }
   }
}

