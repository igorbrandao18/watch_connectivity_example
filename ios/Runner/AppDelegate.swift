import UIKit
import Flutter
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
  
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "com.example.watch", binaryMessenger: flutterViewController.binaryMessenger)

    GeneratedPluginRegistrant.register(with: self)

    // Iniciar a sessão de WatchConnectivity
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }

    // Configurar para receber mensagem do Flutter
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "sendMessage", let args = call.arguments as? [String: Any], let text = args["text"] as? String {
        self?.sendMessageToWatch(text: text)
        result("Mensagem enviada ao Apple Watch via iPhone: \(text)")
      } else {
        result(FlutterError(code: "UNAVAILABLE", message: "Erro ao enviar mensagem", details: nil))
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Enviar a mensagem ao Apple Watch
  func sendMessageToWatch(text: String) {
    if WCSession.default.isReachable {
      let message = ["text": text]
      WCSession.default.sendMessage(message, replyHandler: nil) { error in
        print("Erro ao enviar mensagem para o Apple Watch: \(error.localizedDescription)")
      }
    } else {
      print("Apple Watch não está acessível.")
    }
  }

  // Delegate para receber mensagens do Apple Watch
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: (([String : Any]) -> Void)? = nil) {
    if let textReceived = message["text"] as? String {
      print("Texto recebido do Apple Watch: \(textReceived)")
      
      // Enviar a mensagem recebida ao Flutter via MethodChannel
      methodChannel?.invokeMethod("receivedMessage", arguments: textReceived)

      // Exemplo: Enviar uma resposta de volta ao Apple Watch
      if let replyHandler = replyHandler {
        replyHandler(["response": "Mensagem recebida no iPhone"])
      }
    }
  }

  // Delegate para ativar a sessão de WatchConnectivity
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("Erro ao ativar a sessão: \(error.localizedDescription)")
    } else {
      print("Sessão ativada com sucesso no iPhone.")
    }
  }

  // Implementação obrigatória para WCSessionDelegate
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }
}
