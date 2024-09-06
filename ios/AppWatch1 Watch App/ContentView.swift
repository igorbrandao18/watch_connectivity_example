import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var messageFromPhone = "Nenhuma mensagem recebida"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            Button(action: {
                sendMessageToPhone()
            }) {
                Text("Enviar mensagem para o iPhone")
            }

            Text("Recebido do iPhone: \(messageFromPhone)")
                .padding()
        }
        .padding()
        .onAppear {
            activateSession()
        }
    }

    // Função para ativar a sessão de WatchConnectivity
    func activateSession() {
        // Verifica se o WCSession está suportado no dispositivo
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.activationState != .activated {
                session.delegate = WatchSessionDelegate.shared
                session.activate()
            }

            // Listen for messages from the iPhone
            WatchSessionDelegate.shared.onMessageReceived = { message in
                if let response = message["response"] as? String {
                    messageFromPhone = response
                }
            }
        } else {
            print("WatchConnectivity não é suportado neste dispositivo.")
        }
    }

    // Função para enviar mensagem ao iPhone
    func sendMessageToPhone() {
        let message = ["text": "Olá, iPhone!"]
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Erro ao enviar mensagem: \(error.localizedDescription)")
            }
        } else {
            print("iPhone não está acessível")
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    static let shared = WatchSessionDelegate()
    var onMessageReceived: (([String: Any]) -> Void)?

    // Delegate chamado quando uma mensagem é recebida
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        onMessageReceived?(message)
    }

    // Método obrigatório: ativação da sessão foi concluída
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Erro na ativação da sessão: \(error.localizedDescription)")
        } else {
            print("Sessão ativada com sucesso")
        }
    }

    // Esse método é opcional, mas pode ajudar a monitorar a acessibilidade
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("iPhone acessível")
        } else {
            print("iPhone não está acessível")
        }
    }

    // Esses métodos são necessários apenas no iOS, não no watchOS
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Pode ser deixado vazio ou com lógica específica
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Reative a sessão, se necessário
        session.activate()
    }
    #endif
}

#Preview {
    ContentView()
}
