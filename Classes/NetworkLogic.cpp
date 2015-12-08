//
//  NetworkLogic.cpp
//  MyPhoton
//
//  Created by AiharaKohei on 2015/12/08.
//
//
#include "NetworkLogic.h"

static const ExitGames::Common::JString appId = L"<your appId>"; // set your app id here
static const ExitGames::Common::JString appVersion = L"1.0";
static const ExitGames::Common::JString PLAYER_NAME = "iOS";

// ---------- インスタンスメソッド
// コンストラクタ
NetworkLogic::NetworkLogic():
client(*this, appId, appVersion, PLAYER_NAME+GETTIMEMS(), ExitGames::Photon::ConnectionProtocol::UDP, ExitGames::LoadBalancing::AuthenticationValues(), true, false)
{  }

// デストラクタ
NetworkLogic::~NetworkLogic()
{  }

// 初期化
bool NetworkLogic::init()
{
    return true;
}

void NetworkLogic::connect(void)
{
    this->client.connect();
    this->state = State::CONNECTING;
}

void NetworkLogic::disconnect(void)
{
    this->client.disconnect();
}

void NetworkLogic::opCreateRoom(void)
{
    ExitGames::Common::JString tmp;
    this->client.opCreateRoom(tmp=GETTIMEMS(), true, true, 4, ExitGames::Common::Hashtable(), ExitGames::Common::JVector<ExitGames::Common::JString>(), ExitGames::Common::JString(), ExitGames::LoadBalancing::LobbyType::DEFAULT, INT_MAX/2, 10000);
    this->state = State::JOINING;
}

void NetworkLogic::opJoinRandomRoom(void)
{
    this->client.opJoinRandomRoom();
}

void NetworkLogic::run(void)
{
    if(this->input == Input::EXIT && this->state != State::DISCONNECTING && this->state != State::DISCONNECTED)
    {
        disconnect();
        this->state = State::DISCONNECTING;
    }
    else
    {
        switch(this->state)
        {
            case State::INITIALIZED:
                this->connect();
                break;
            case State::CONNECTING:
                break;
            case State::CONNECTED:
                switch(this->input)
            {
                case Input::CREATE_GAME:
                {
                    this->opCreateRoom();
                    break;
                }
                case Input::JOIN_RANDOM_GAME:
                {
                    this->opJoinRandomRoom();
                    this->state = State::JOINING;
                    break;
                }
                default:
                    break;
            }
                break;
            case State::JOINING:
                break;
            case State::JOINED:
                sendEvent();
                switch(this->input)
            {
                case Input::CREATE_GAME:
                    this->client.opLeaveRoom();
                    this->state = State::LEAVING;
                    break;
                case Input::JOIN_RANDOM_GAME:
                    this->client.opLeaveRoom(true);
                    this->state = State::LEAVING;
                    break;
                default:
                    break;
            }
                break;
            case State::LEAVING:
                break;
            case State::LEFT:
                this->state = State::CONNECTED;
                break;
            case State::DISCONNECTING:
                break; 
            default:
                break;        
        }
    }
    this->input = Input::NON;
    this->client.service();
}

void NetworkLogic::sendEvent(void)
{
    static int64 count = 0;
    this->client.opRaiseEvent(false, ++count, 0);
}

void NetworkLogic::sendEvent(nByte code, ExitGames::Common::Hashtable* eventContent)
{
    this->client.opRaiseEvent(true, eventContent, 1, code);
}

void NetworkLogic::setLastInput(Input newInput)
{
    this->input = newInput;
}

NetworkLogic::State NetworkLogic::getState(void) const
{
    return this->state;
}

bool NetworkLogic::isRoomExists(void)
{
    return !this->client.getRoomList().getIsEmpty();
}

const int NetworkLogic::getPlayerId() const
{
    return this->playerId;
}

void NetworkLogic::customEventAction(int playerNr, nByte eventCode, const ExitGames::Common::Object& eventContent)
{
    ExitGames::Common::Hashtable* event;
    
    switch (eventCode)
    {
        case 1:
            event = ExitGames::Common::ValueObject<ExitGames::Common::Hashtable*>(eventContent).getDataCopy();
            float x = ExitGames::Common::ValueObject<float>(event->getValue(1)).getDataCopy();
            float y = ExitGames::Common::ValueObject<float>(event->getValue(2)).getDataCopy();
            eventQueue.push({static_cast<float>(playerNr), x, y});
            break;
    }
}

void NetworkLogic::connectReturn(int errorCode, const ExitGames::Common::JString& errorString)
{
    this->state = (errorCode) ? State::DISCONNECTING : State::CONNECTED;
}

void NetworkLogic::disconnectReturn(void)
{
    this->state = State::DISCONNECTED;
}

void NetworkLogic::createRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& /*gameProperties*/, const ExitGames::Common::Hashtable& /*playerProperties*/, int errorCode, const ExitGames::Common::JString& errorString)
{
    if(errorCode)
    {
        this->state = State::CONNECTED;
        return;
    }
    this->state = State::JOINED;
    this->playerId = localPlayerNr;
}

void NetworkLogic::joinRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& /*gameProperties*/, const ExitGames::Common::Hashtable& /*playerProperties*/, int errorCode, const ExitGames::Common::JString& errorString)
{
    if(errorCode)
    {
        this->state = State::CONNECTED;
        return;
    }
    this->state = State::JOINED;
    this->playerId = localPlayerNr;
}

void NetworkLogic::joinRandomRoomReturn(int localPlayerNr, const ExitGames::Common::Hashtable& /*gameProperties*/, const ExitGames::Common::Hashtable& /*playerProperties*/, int errorCode, const ExitGames::Common::JString& errorString)
{
    if(errorCode)
    {
        this->state = State::CONNECTED;
        return;
    }
    this->state = State::JOINED;
    this->playerId = localPlayerNr;
}

void NetworkLogic::leaveRoomReturn(int errorCode, const ExitGames::Common::JString& errorString)
{
    this->state = (errorCode) ? State::DISCONNECTING : State::LEFT;
}

void NetworkLogic::onAvailableRegions(const ExitGames::Common::JVector<ExitGames::Common::JString>& availableRegions, const ExitGames::Common::JVector<ExitGames::Common::JString>& availableRegionServers)
{
    this->client.selectRegion(availableRegions[0]);
}
