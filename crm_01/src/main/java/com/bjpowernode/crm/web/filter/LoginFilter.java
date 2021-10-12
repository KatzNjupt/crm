package com.bjpowernode.crm.web.filter;

import com.bjpowernode.crm.settings.domain.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("进入到验证登录的过滤器");

        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String path = request.getServletPath();
        if ("/login.jsp".equals(path) || "/settings/user/login.do".equals(path)){

            filterChain.doFilter(servletRequest,servletResponse);
        }
        else {

            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            if (user!=null){
                //user不为空，说明登陆过，放行
                filterChain.doFilter(servletRequest,servletResponse);
            }else {
                //没有登陆过
                //重定向到登录页
            /*
            重定向的路径怎么写？
                在实际项目开发中，不论前端后端，一律使用绝对路径
                转发：
                    使用的一种特殊的绝对路径，前面不加/项目名，也成为内部路径
                重定向：
                    使用传统绝对路径写法，必须以/项目名开头

             为什么请求转发不行：
                转发之后，路径会停留在老路径上，而不是跳转之后最新资源的路径
                我们应该在为用户设置跳转到登录页的同时，将浏览器地址栏路径自动设置为当前登录页路径
             */
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
        }



    }
}
