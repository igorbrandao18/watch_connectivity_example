import Flutter
import UIKit
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

    // Iniciar sessão de WatchConnectivity se estiver disponível
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }

    // Escutar mensagens vindas do Flutter
    methodChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "sendMessageToAppDelegate" {
        if let message = call.arguments as? String {
          print("Mensagem recebida do Flutter: \(message)")
          result("Mensagem recebida com sucesso no AppDelegate!")
        } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Argumento inválido", details: nil))
        }
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Delegate method chamado quando o app recebe uma mensagem do Apple Watch
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    if let textReceived = message["text"] as? String {
      print("Texto recebido do Apple Watch: \(textReceived)")
      
      // Enviar a mensagem recebida ao Flutter via FlutterMethodChannel
      methodChannel?.invokeMethod("receivedMessage", arguments: textReceived)
      
      // Exemplo: Enviar resposta de volta ao Apple Watch
      session.sendMessage(["response": "Texto recebido com sucesso!"], replyHandler: nil, errorHandler: nil)
    }
  }

  // Método obrigatório para conformar com WCSessionDelegate
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    if let error = error {
      print("Erro ao ativar sessão: \(error.localizedDescription)")
    } else {
      print("Sessão ativada com sucesso")
    }
  }

  // Métodos obrigatórios para conformar com WCSessionDelegate
  func sessionDidBecomeInactive(_ session: WCSession) {
    // Código para lidar com sessão inativa, se necessário
  }

  func sessionDidDeactivate(_ session: WCSession) {
    // Reativar uma nova sessão, se necessário
    session.activate()
  }
}
