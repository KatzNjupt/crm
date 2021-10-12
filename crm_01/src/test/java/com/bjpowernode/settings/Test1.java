package com.bjpowernode.settings;

import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.MD5Util;
import org.junit.Test;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Test1 {
    @Test
    public void test1(){
        /*
        //验证失效时间
        //失效时间
        String expireTime = "2019-10-10 10:10:10";
        //当前系统时间
        String currentTime = DateTimeUtil.getSysTime();
        int count = expireTime.compareTo(currentTime);
        */

        /*
        String lockState = "0";
        if ("0".equals(lockState)){
            //账号锁定
        }
        */
        /*
        //浏览器端ip地址
        String ip = "192.168.1.1";
        //允许访问的ip地址
        String allowIps = "192.168.1.1,192.168.1.2";

        if (allowIps.contains(ip)){
            //有效ip地址，允许访问系统
        }else {
            //ip地址受限，请联系管理员
        }*/


        String pwd = "123";
        pwd = MD5Util.getMD5(pwd);
        System.out.println(pwd);
    }
}
