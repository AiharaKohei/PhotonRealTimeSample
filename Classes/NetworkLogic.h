//
//  NetworkLogic.h
//  MyPhoton
//
//  Created by AiharaKohei on 2015/12/08.
//
//

#ifndef _NetworkLogic__
#define _NetworkLogic__

#include "cocos2d.h"
#include "LoadBalancing-cpp/inc/Client.h"
#include <array>
#include <queue>

class NetworkLogic : private ExitGames::LoadBalancing::Listener, public cocos2d::Ref
{
// ---------- 定数
public:
    enum class State
    {
        INITIALIZED = 0,
        CONNECTING,
        CONNECTED,
        JOINING,
        JOINED,
        LEAVING,
        LEFT,
        DISCONNECTING,
        DISCONNECTED,
        
        SIZE
    };
    enum class Input
    {
        NON = 0,
        EXIT,
        CREATE_GAME,
        JOIN_RANDOM_GAME,
        
        SIZE
    };
    
// ---------- クラスメソッド
public:
    CREATE_FUNC(NetworkLogic)
    
// ---------- インスタンス変数
private:
    ExitGames::LoadBalancing::Client client;
    Input input { Input::NON };
    State state { State::INITIALIZED };
    int playerId { 0 };
public:
    std::queue<std::array<float, 3>> eventQueue; // イベントキュー

// ---------- インスタンスメソッド
public:
    NetworkLogic();   // コンストラクタ
    ~NetworkLogic();  // デストラクタ
    bool init();    // 初期化
    
    void run();
    void connect();
    void opCreateRoom();
    void opJoinRandomRoom();
    void disconnect();
    void sendEvent();
    void sendEvent(nByte code, ExitGames::Common::Hashtable* eventContent);    // イベントを送信するメソッド
    
    void setLastInput(Input newInput);
    State getState() const;
    const int getPlayerId()const;
    bool isRoomExists();    // ルームが存在するか否かを返すメソッド
    
private:
    // receive and print out debug out here
    virtual void debugReturn(int debugLevel, const ExitGames::Common::JString& string){};
    
    // implement your error-handling here
    virtual void connectionErrorReturn(int errorCode){};
    virtual void clientErrorReturn(int errorCode){};
    virtual void warningReturn(int warningCode){};
    virtual void serverErrorReturn(int errorCode){};
    
    // events, triggered by certain operations of all players in the same room
    virtual void joinRoomEventAction(int playerNr, const ExitGames::Common::JVector<int>& playernrs, const ExitGames::LoadBalancing::Player& player){};
    virtual void leaveRoomEventAction(int playerNr, bool isInactive){};
    
    virtual void customEventAction(int playerNr, nByte eventCode, const ExitGames::Common::Object& eventContent);
    
    // callbacks for operations on server
    virtual void connectReturn(int errorCode, const ExitGames::Common::JString& errorString);
    virtual void disconnectReturn(void);
    virtual void createRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& gameProperties, const ExitGames::Common::Hashtable& playerProperties, int errorCode, const ExitGames::Common::JString& errorString);
    virtual void joinRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& gameProperties, const ExitGames::Common::Hashtable& playerProperties, int errorCode, const ExitGames::Common::JString& errorString);
    virtual void joinRandomRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& gameProperties, const ExitGames::Common::Hashtable& playerProperties, int errorCode, const ExitGames::Common::JString& errorString);
    virtual void leaveRoomReturn(int errorCode, const ExitGames::Common::JString& errorString);
    virtual void joinLobbyReturn(void){};
    virtual void leaveLobbyReturn(void){};
    
    virtual void onAvailableRegions(const ExitGames::Common::JVector<ExitGames::Common::JString>& availableRegions, const ExitGames::Common::JVector<ExitGames::Common::JString>& availableRegionServers);
};

#endif /* defined(_NetworkLogic__) */
