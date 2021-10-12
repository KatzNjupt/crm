package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.settings.service.impl.UserServiceImpl;
import com.bjpowernode.crm.utils.MD5Util;
import com.bjpowernode.crm.utils.PrintJson;
import com.bjpowernode.crm.utils.ServiceFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入到用户控制器");

        String path = request.getServletPath();

        if ("/settings/user/login.do".equals(path)){

            login(request,response);

        }else if ("/settings/user/xxx.do".equals(path)){

            //xxx(request,response);
        }
    }

    private void login(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到验证登录的操作");

        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        //将密码的明文转为MD5的密文
        loginPwd = MD5Util.getMD5(loginPwd);
        //接受ip
        String ip = request.getRemoteAddr();
        System.out.println("ip地址" + ip);

        //为了业务层开发，统一使用代理类形态的接口对象
        UserService us = (UserService) ServiceFactory.getService(new UserServiceImpl());

        try {
            User user = us.login(loginAct,loginPwd,ip);
            request.getSession().setAttribute("user",user);
            //如果程序执行到此处，说明业务层没有为Controller抛异常
            //表示登录成功
            /*
				data
					{"success":true}
			 */
            PrintJson.printJsonFlag(response,true);

        }catch (Exception e){
            e.printStackTrace();
            //说明业务层验证失败，抛出了异常
            //表示登录失败
            /*
			data
				{"success":true/false,"msg":哪错了}
	    	 */
            String msg = e.getMessage();
            /*
                现在controller需要为ajax提供多项信息
                手段一：将多项信息打包成map，将map解析完json串
                手段二：创建一个vo
                            private boolean success;
                            private String msg;
             */
            Map<String,Object> map = new HashMap<String, Object>();
            map.put("success",false);
            map.put("msg",msg);
            PrintJson.printJsonObj(response,map);
        }

    }
}
