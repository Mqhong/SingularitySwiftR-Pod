//
//  LinkDao.swift
//  ChatDemo
//
//  Created by mm on 16/1/7.
//  Copyright © 2016年 mm. All rights reserved.
//

import Foundation
import SwiftR

public enum LinkState{
    case Connecting
    case Connected
    case Disconnected
}

@objc protocol LinkDaoDelegate{
    /**
     登录成功的回调
     
     :param: Dict 服务器返回的数据
     */
    optional func LinkDao_LoginCallBack(request:AnyObject?)
    /**
     获取目标信息回调
     
     :param: request chat_session_id 聊天会话 id target_id 目标id target_name 目标名称 target_picture 目标头像
     */
    optional func LinkDao_ReceiveTargetInfo(request:AnyObject?)
    /**
     获取用户会话列表的回调
     
     :param: request
     {
     chat_session_id //聊天会话 id
     chat_session_type //聊天会话类型 0:用户 1:群
     message_count //会话未读消息条数
     last_sender_id //最后发送者 id
     last_message //最后条消息
     last_message_time //最后条消息发送时间
     为1是群id
     last_message_type //最后条消息类型
     target_id //会话目标 id ,会话类型为 0 是用户 id,
     target_name //
     目标名称 目标头像
     target_picture //
     target_online_status //目标在线状态(仅用于 chat_session_type 为用户时)
     },
     */
    optional func LinkDao_ReceiveChatSessionList(request:AnyObject?)
    
    /**
     获取用户未读信息回调
     
     :param: request {
     chat_session_id //聊天会话 id
     chat_session_type //聊天会话类型 0:用户 1:群
     sender_id //最后发送者 id
     message_id //消息 id
     },
     {
     ```
     },
     */
    optional func LinkDao_ReceiveUnreadMessages(request:AnyObject?)
    
    
    /**
     获取用户历史消息回调
     
     :param: request ddd
     [
     {
     chat_session_id //聊天会话 id
     history_messages:
     chat_session_id //聊天会话 id
     chat_session_type //聊天会话类型 0:用户 1:群
     sender_id //发送者 id
     message_id //消息id
     message //消息内容
     },
     message_time //消息发送时间
     message_type //消息类型
     unread_messages:{
     ...... //同上
     } ]
     */
    optional func LinkDao_ReceiveHistoryMessages(request:AnyObject?)
    
    /**
     发送消息的回调
     
     :param: request
     {
     chat_session_id //聊天会话 id
     chat_session_type //聊天会话类型 0:用户 1:群
     sender_id //最后发送者 id
     message_id //消息 id
     message //消息内容
     message_time //消息发送时间
     // token message_type //消息类型
     }
     */
    optional func LinkDao_MessageCallback(request:AnyObject?)
    
    
    /**
     接收消息
     
     :param: request
     {
     chat_session_id //聊天会话 id
     chat_session_type //聊天会话类型 0:用户 1:群
     sender_id //发送者 id
     message_id //消息 id
     message //消息内容
     message_time //消息发送时间
     }
     */
    optional func LinkDao_ReceiveMessage(request:AnyObject?)
    
    /**
     聊天用户(对方)在线状态改变
     
     :param: request
     {
     user_id //用户 id
     user_name //用户名称
     user_picture //用户图片
     user_onli  //在线状态 0:离线 1:在线
     }
     */
    optional func LinkDao_ChatUserStatusChanged(request:AnyObject?)
    
}



class LinkDao: NSObject {
        var LinkDaostate:LinkState!
        weak var delegate : LinkDaoDelegate?
        var chatHub:Hub!
        var hubConnection:SignalR!
        
        /**
         初始化连接池，并监听回调
         */
        func _initLinkDao(){
        hubConnection = SwiftR.connect("http://123.56.130.232:8089/signalr") { [weak self] connection in
        
        self?.chatHub = connection.createHubProxy("chatHub")
        
        //监听loginCallback方法
        self?.chatHub.on("loginCallback", callback: { (args) -> () in
            print("接收到loginCallback回调方法")
        self?.delegate?.LinkDao_LoginCallBack!(args)
        
        })
        
        //监听获取目标信息
        self?.chatHub.on("receiveTargetInfo", callback: { (args) -> () in
            print("接收到获取目标信息")
            self?.delegate?.LinkDao_ReceiveTargetInfo!(args)
            })
        
        //监听获取用户会话列表
        self?.chatHub.on("receiveChatSessionList", callback: { (args) -> () in
            print("接收到用户会话列表")
            self?.delegate?.LinkDao_ReceiveChatSessionList!(args)
            })
        
        
        //监听获取用户未读消息
        self?.chatHub.on("receiveUnreadMessages", callback: { (args) -> () in
            print("接收到用户未读消息")
            self?.delegate?.LinkDao_ReceiveUnreadMessages!(args)
            })
        
        //监听获取用户历史消息
        self?.chatHub.on("receiveHistoryMessages", callback: { (args) -> () in
            print("接收到历史消息")
            self?.delegate?.LinkDao_ReceiveUnreadMessages!(args)
            })
        
        //监听发送消息的回调
        self?.chatHub.on("messageCallback", callback: { (args) -> () in
            print("接收到发送消息的回调")
            self?.delegate?.LinkDao_MessageCallback!(args)
            })
        
        //监听接收消息
        self?.chatHub.on("receiveMessage", callback: { (args) -> () in
            print("接收到消息")
            self?.delegate?.LinkDao_ReceiveMessage!(args)
            })
        
        //监听聊天用户(对方)在线状态
        self?.chatHub.on("chatUserStatusChanged", callback: { (args) -> () in
            print("接收到对方在线状态")
            self?.delegate?.LinkDao_ChatUserStatusChanged!(args)
            })
        
        
        connection.starting = { [weak self] in
                print("Starting...")
                self!.LinkDaostate = LinkState.Connecting
        }
        
        connection.reconnecting = { [weak self] in
                print("Reconnecting...")
                self!.LinkDaostate = LinkState.Connecting
        }
        
        connection.connected = { [weak self] in
            print("Connected. Connection ID: \(connection.connectionID!)")
            self!.LinkDaostate = LinkState.Connected
        }
        
        connection.reconnected = { [weak self] in
            print("Reconnected. Connection ID: \(connection.connectionID!)")
            self!.LinkDaostate = LinkState.Connected
        }
        
        connection.disconnected = { [weak self] in
            print("Disconnected.")
            self!.LinkDaostate = LinkState.Disconnected
        }
        
        connection.connectionSlow = { print("Connection slow...") }
        
        connection.error = {
                    error in print("Error: \(error)")
            
                    if let source = error?["source"] as? String where source == "TimeoutException" {
                print("Connection timed out. Restarting...")
                connection.start()
                    }
        }
        
        }
        
        }
        
        
        //MARK:- 心跳
        /**
        心跳
        */
        func heart(){
            chatHub.invoke("heart", arguments: [])
        }
        
        //MARK:- 确认消息
        /**
        确认消息
        
        :param: dict {
        message_id //消息 id chat_session_id//聊天会话 id
        }
        */
        func confirmMessage(dict:Dictionary<String,String>){
            chatHub.invoke("confirmMessage", arguments: [dict])
        }
        
        //MARK:- 发送消息
        /**
        发送消息
        
        :param: dict {
        target_id //发送目标的 id
        content //发送内容
        message_token //   token,调用者随机生成 message_type //
        }
        */
        func messageToUser(dict:Dictionary<String,String>){
            chatHub.invoke("messageToUser", arguments: [dict])
        }
        
        //MARK:- 获取用户历史消息
        /**
        获取用户历史消息
        
        :param: dict {
        chat_session_id //聊天会话 id
        size //消息条数
        before_message_id //在哪条消息之前,可选
        }
        */
        func getHistoryMessages(dict:Dictionary<String,String>){
            chatHub.invoke("getHistoryMessages", arguments: [dict])
        }
        
        //MARK:- 获取用户未读信息
        /**
        获取用户未读信息
        
        :param: dict {
        chat_session_id //聊天会话id
        }
        */
        func getUnreadMessages(dict:Dictionary<String,String>){
            chatHub.invoke("getUnreadMessages", arguments: [dict])
        }
        
        //MARK:- 获取用户会话列表
        /**
        获取用户会话列表
        */
        func getChatSessionList(){
            chatHub.invoke("getChatSessionList", arguments: nil)
        }
        
        //MARK:- 获取目标信息
        /**
        获取目标信息
        
        :param: dict {
        target_id //目标id chat_session_type //聊天会话类型 chat_session_id //聊天会话 id
        }
        */
        func getTargetInfo(dict:Dictionary<String,String>){
            chatHub.invoke("getTargetInfo", arguments: [dict])
        }
        
        
        //MARK:- 调用服务器的登录
        /**
        调用服务器的登录
        
        :param: token 需要的参数 token
        
        :returns: 返回是否成功
        */
        func externalLogin(token:String){
            chatHub.invoke("externalLogin", arguments: [token])
        }
        
}
