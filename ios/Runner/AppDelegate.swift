import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, WCSessionDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Iniciar sessão de WatchConnectivity se estiver disponível
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Delegate method chamado quando o app recebe uma mensagem do Apple Watch
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    if let textReceived = message["text"] as? String {
      // Aqui você pode manipular a mensagem recebida do Apple Watch
      print("Texto recebido do Apple Watch: \(textReceived)")
      
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

  // Método obrigatório para conformar com WCSessionDelegate
  func sessionDidBecomeInactive(_ session: WCSession) {
    // Código para lidar com sessão inativa, se necessário
  }

  // Método obrigatório para conformar com WCSessionDelegate
  func sessionDidDeactivate(_ session: WCSession) {
    // Reativar uma nova sessão, se necessário
    session.activate()
  }
}
