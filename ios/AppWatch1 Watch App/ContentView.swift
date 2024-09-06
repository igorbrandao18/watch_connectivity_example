import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var textToSend = ""

    var body: some View {
        VStack {
            TextField("Digite sua mensagem", text: $textToSend)
                .padding()

            Button("Enviar para iPhone") {
                sendMessageToiPhone()
            }
            .padding()
        }
        .onAppear {
            activateSession()
        }
    }

    // Função para ativar a sessão de WatchConnectivity
    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = WatchSessionDelegate.shared
            session.activate()
        } else {
            print("WatchConnectivity não é suportado neste dispositivo.")
        }
    }

    // Função para enviar a mensagem digitada para o iPhone
    func sendMessageToiPhone() {
        if WCSession.default.isReachable {
            let message = ["text": textToSend]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Erro ao enviar mensagem: \(error.localizedDescription)")
            }
            
            // Limpar o campo de texto após o envio
            textToSend = ""
        } else {
            print("iPhone não está acessível")
        }
    }
}

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    static let shared = WatchSessionDelegate()

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Aqui você pode manipular a mensagem recebida do iPhone, se necessário
        if let response = message["response"] as? String {
            print("Resposta recebida do iPhone: \(response)")
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Erro na ativação da sessão: \(error.localizedDescription)")
        } else {
            print("Sessão ativada com sucesso")
        }
    }
}
