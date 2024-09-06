import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @State private var textToSend = ""
    @State private var receivedText = "" // Armazenar o texto recebido

    var body: some View {
        VStack {
            TextField("Digite sua mensagem", text: $textToSend)
                .padding()

            Button("Enviar para iPhone") {
                sendMessageToiPhone()
            }
            .padding()

            Text("Recebido do iPhone: \(receivedText)")
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
            print("Sessão de WatchConnectivity ativada no Apple Watch.")
        } else {
            print("WatchConnectivity não é suportado neste dispositivo.")
        }
    }

    // Função para enviar a mensagem digitada para o iPhone via WatchConnectivity
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

    @Published var receivedText = ""  // Estado para armazenar a mensagem recebida

    // Método obrigatório: Chamado quando a ativação da sessão for concluída
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Erro na ativação da sessão: \(error.localizedDescription)")
        } else {
            print("Sessão ativada com sucesso no Apple Watch.")
        }
    }

    // Implementação do método para receber mensagens do iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let text = message["text"] as? String {
            DispatchQueue.main.async {
                // Atualizar a interface do usuário com a mensagem recebida
                self.receivedText = text
                print("Texto recebido do iPhone: \(text)")
            }
        }
    }
    
    // Implementação condicional para os métodos disponíveis apenas no iOS
    #if os(iOS)
    // Método obrigatório no iOS
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Comportamento específico para o iOS
        print("Sessão ficou inativa no iOS")
    }

    // Método obrigatório no iOS
    func sessionDidDeactivate(_ session: WCSession) {
        // Reativar a sessão no iOS
        session.activate()
        print("Sessão foi desativada no iOS, reativando")
    }
    #endif
}
