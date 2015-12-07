#include "HelloWorldScene.h"

USING_NS_CC;

HelloWorld::HelloWorld()
{}

HelloWorld::~HelloWorld()
{}

bool HelloWorld::init()
{
    if (!Scene::init()) return false;
   
    EventListenerTouchOneByOne* listener { EventListenerTouchOneByOne::create() };
    listener->onTouchBegan = CC_CALLBACK_2(HelloWorld::onTouchBegan, this);
    this->getEventDispatcher()->addEventListenerWithSceneGraphPriority(listener, this);
    
    // Photonネットワーククラスのインスタンスを作成
    this->networkLogic = NetworkLogic::create();
    CC_SAFE_RETAIN(this->networkLogic);
    
    scheduleUpdate();
    
    return true;
}

bool HelloWorld::onTouchBegan(cocos2d::Touch* touch, cocos2d::Event* event)
{
    if (networkLogic->getPlayerId())
    {
        this->addParticle(networkLogic->getPlayerId(), touch->getLocation().x, touch->getLocation().y);
        
        // イベント（タッチ座標）を送信
        ExitGames::Common::Hashtable* eventContent = new ExitGames::Common::Hashtable();
        eventContent->put<int, float>(1, touch->getLocation().x);
        eventContent->put<int, float>(2, touch->getLocation().y);
        networkLogic->sendEvent(1, eventContent);
    }
    
    return true;
}

void HelloWorld::update(float delta)
{
    networkLogic->run();
    
    switch (networkLogic->getState()) {
        case NetworkLogic::State::CONNECTED:
        case NetworkLogic::State::LEFT:
        {
            // ルームが存在すればジョイン、なければ作成する
            if (networkLogic->isRoomExists())
            {
                CCLOG("Join");
                networkLogic->setLastInput(NetworkLogic::Input::JOIN_RANDOM_GAME);
            } else
            {
                CCLOG("Create");
                networkLogic->setLastInput(NetworkLogic::Input::CREATE_GAME);
            }
            break;
        }
        case NetworkLogic::State::DISCONNECTED:
        {
            // 接続が切れたら再度接続
            networkLogic->connect();
            break;
        }
        case NetworkLogic::State::CONNECTING:
        case NetworkLogic::State::JOINED:
        case NetworkLogic::State::JOINING:
        case NetworkLogic::State::LEAVING:
        case NetworkLogic::State::DISCONNECTING:
        default:
            break;
    }
    
    while (!networkLogic->eventQueue.empty())
    {
        std::array<float, 3> arr = networkLogic->eventQueue.front();
        networkLogic->eventQueue.pop();
        
        int playerNr = static_cast<int>(arr[0]);
        float x = arr[1];
        float y = arr[2];
        this->addParticle(playerNr, x, y);
    }
}

void HelloWorld::addParticle(int playerNr, float x, float y)
{
    ParticleSystem* particle;
    switch (playerNr)
    {
        case 1:
            particle = ParticleFire::create();
            break;
        case 2:
            particle = ParticleSmoke::create();
            break;
        case 3:
            particle = ParticleFlower::create();
            break;
        default:
            particle = ParticleSun::create();
            break;
    }
    particle->setDuration(0.1);
    particle->setSpeed(500);
    particle->setPosition(cocos2d::Point(x,y));
    this->addChild(particle);
}
