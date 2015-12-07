#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "NetworkLogic.h"

class HelloWorld : public cocos2d::Scene
{
// ---------- クラスメソッド
public:
    CREATE_FUNC(HelloWorld)
    
// ---------- インスタンス変数
private:
    NetworkLogic* networkLogic;

// ---------- インスタンスメソッド
public:
    HelloWorld();
    ~HelloWorld();
    virtual bool init();
    virtual bool onTouchBegan(cocos2d::Touch* touch, cocos2d::Event* event);

private:
    virtual void update(float delta);
    void addParticle(int playerNr, float x, float y);
};

#endif // __HELLOWORLD_SCENE_H__
