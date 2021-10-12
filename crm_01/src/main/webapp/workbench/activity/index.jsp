<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + 	request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>


<script type="text/javascript">

	$(function(){
		
		//为创建按钮绑定事件，目的是打开添加操作的模态窗口
		$("#addBtn").click(function () {

			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			/*
			操作模态窗口的方式：
				找到需要操作的模态窗口的jQUery对象，调用modal方法，
				为该方法传递参数：
				show打开模态窗口 hide关闭模态窗口
			 */

			//走后台，目的是取用户信息，为所有者下拉框提供信息
			$.ajax({
				url:"workbench/activity/getUserList.do",
				type:"get",
				dataType:"json",
				success:function (data) {
					/*
					data:[{"id":?,"name":?..},{2}...]
					 */
					var html = "<option></option>";
					//遍历出来的每一个n，就是每一个user对象
					$.each(data,function (i,n) {
						html += "<option value='" + n.id + "'>" + n.name + "</option>";
					})

					$("#create-marketActivityOwner").html(html)

					//将当前登录的用户，设置为下拉框默认的选项

					//取得当前登录用户的id
					//在js中使用EL表达式，必须套用在字符串中
					var id = "${user.id}";
					$("#create-marketActivityOwner").val(id)

					//当所有者下拉框处理完毕之后，展现模态窗口
					$("#createActivityModal").modal("show")
				}
			})


		})

		//为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/activity/save.do",
				data:{
					"owner":$.trim($("#create-marketActivityOwner").val()),
					"name":$.trim($("#create-marketActivityName").val()),
					"startDate":$.trim($("#create-startTime").val()),
					"endDate":$.trim($("#create-endTime").val()),
					"cost":$.trim($("#create-cost").val()),
					"description":$.trim($("#create-describe").val())

				},
				type:"post",
				dataType:"json",
				success:function (data) {
					/*
					data:{"success":true/false}
					 */
					if (data.success){
						//添加成功
						//刷新市场活动信息列表 局部刷新
						/*
							$("#activityPage").bs_pagination('getOption', 'currentPage')
								表示操作后停留在当前页
							$("#activityPage").bs_pagination('getOption', 'rowsPerPage')
								表示操作后维持已经设计好的每页展现的记录数

							这两个参数不需要我们进行任何的修改操作
								直接使用即可
						*/
						//做完添加操作后，应该回到第一页，维持每页展现的记录数

						pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						//清空添加操作模态窗口中的数据
						//$("#activityAddForm").reset()
						//此方法无效 用不了
						/*
						jQuery提供了submit方法 没提供reset，这个reset是idea提供的

						采用原生js可以使用reset方法
						将jQuery对象转为dom对象：
							jQuery对象[下标]
						dom转jQuery对象
							$(dom)
						*/

						$("#activityAddForm")[0].reset();

						//关闭添加操作的模态窗口
						$("#createActivityModal").modal("hide");
					}else{
						alert("添加市场活动失败");
					}


				}
			})
		})

		//页面加载完毕后，触发一个方法
        //默认展开列表第一页，每页两条记录
        pageList(1,2);

		//为查询按钮绑定事件，触发pageList方法
        $("#searchBtn").click(function () {
			/*
				点击查询按钮的时候，应该将搜索框中的信息先保存起来,保存到隐藏域
			 */
			$("#hidden-name").val($.trim($("#search-name").val()))
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-startDate").val($.trim($("#search-startDate").val()))
			$("#hidden-endDate").val($.trim($("#search-endDate").val()))
            pageList(1,2);
        })

		//为全选的复选框触发绑定事件，触发全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked);
		})

		/*
		$("input[name=xz]").click(function () {

		})
		//动态生成的元素，不能以普通绑定事件的形式来进行操作
		 */
		/*
		动态生成的元素，要以on方法的形式来触发事件
		语法：
			$(需要绑定的有效的外层函数).on（绑定事件的方式，需要绑定的元素的jQuery对象，回调函数）
		 */
		$("#activityBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		})


		//为删除按钮绑定事件，执行市场活动删除操作
		$("#delete-Btn").click(function () {
			//找到复选框中的所有打钩的jquery对象
			var $xz = $("input[name=xz]:checked");

			if ($xz.lenth==0){
				//没选择
			}else{
				//选了 一条或多条
				//url:workbench/activity/delete.do?id=xxx&id=xxx

				if (confirm("确定删除所选择记录吗？")){

					//拼接参数
					var param = "";
					//将$zx中每一个dom对象遍历出来，取其value值，就相当于取得了需要删除的记录的id
					for (var i=0;i<$xz.length;i++){
						param += "id=" + $($xz[i]).val();
						//如果不是最后一个元素，需要追加&
						if (i<$xz.length-1){
							param += "&";
						}
					}

					//alert(param);
					$.ajax({
						url:"workbench/activity/delete.do",
						data:param,
						type:"post",
						dataType:"json",
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if (data.success){
								//删除成功，回到第一页
								pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

							}else {
								alert("删除市场活动失败");
							}
						}
					})

				}




			}
		})

		//为修改按钮绑定事件，打开修改操作的模态窗口
		$("#editBtn").click(function () {

			var $xz = $("input[name=xz]:checked")

			if ($xz.length==0){
				alert("请选择需要修改的记录")
			}else if ($xz.length>1){
				alert("只能选择一天记录进行修改")
			}else {
				//一定只选了一条
				var id = $xz.val();
				$.ajax({
					url:"workbench/activity/getUserListAndActivity.do",
					data:{
						"id":id
					},
					type:"get",
					dataType:"json",
					success:function (data) {
						/*
						data
						{"uList"：[{用户1}，{用户2}],"a":{市场活动}}
						 */

						//处理所有者下拉框
						var html = "<option></option>";

						$.each(data.uList,function (i,n) {
							html += "<option value='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-owner").html(html)

						//处理单挑Activity
						$("#edit-id").val(data.a.id)
						$("#edit-name").val(data.a.name)
						$("#edit-owner").val(data.a.owner)
						$("#edit-startDate").val(data.a.startDate)
						$("#edit-endDate").val(data.a.endDate)
						$("#edit-cost").val(data.a.cost)
						$("#edit-descrption").val(data.a.description)

						//所有值都处理完毕之后，打开修改操作的模态窗口
						$("#editActivityModal").modal("show");


					}
				})
			}
		})

		//为更新按钮绑定事件,执行市场活动修改
		/*
		在实际项目开发中，一定先做添加，再做修改
		所有，为了节省开发时间，修改操作copy添加操作
		 */
		$("#updateBtn").click(function () {
			$.ajax({
				url:"workbench/activity/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),
					"name":$.trim($("#edit-name").val()),
					"startDate":$.trim($("#edit-startDate").val()),
					"endDate":$.trim($("#edit-endDate").val()),
					"cost":$.trim($("#edit-cost").val()),
					"description":$.trim($("#edit-descrption").val())

				},
				type:"post",
				dataType:"json",
				success:function (data) {
					/*
					data:{"success":true/false}
					 */
					if (data.success){
						//修改成功
						//刷新市场活动信息列表 局部刷新
						//修改后，维持当前页，维持每页展现的记录数
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));



						//关闭修改操作的模态窗口
						$("#editActivityModal").modal("hide");
					}else{
						alert("修改市场活动失败")
					}


				}
			})		})
	});

	/*
	    对于所有的关系型数据库，做前段的分页相关操作的基础组件
	    就是pageNo和pageSize
	    pageNo表示当前页的页码
	    pageSize表示每页展现的记录数

	    pageList方法就是发出ajax请求到后台，从后台取得最新的市场活动信息列表数据
	        通过响应回来的数据，局部刷新市场活动信息列表

	    什么情况下，需要刷新列表，调用pageList方法：
	    1.点击左侧菜单中的“市场活动”超链接
	    2.添加 修改 删除后需要刷新市场活动列表
	    3.点击查询按钮的时候
	    4.点击分页组件的时候

	    以上6个操作执行完毕之后，必须调用pageList方法刷新市场活动信息列表
	 */
	function pageList(pageNo,pageSize) {

		//将全选的复选框的沟子干掉
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中的信息取出来，重写赋予搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()))
		$("#search-owner").val($.trim($("#hidden-owner").val()))
		$("#search-startDate").val($.trim($("#hidden-startDate").val()))
		$("#search-endDate").val($.trim($("#hidden-endDate").val()))

        $.ajax({
            url:"workbench/activity/pageList.do",
            data:{
                "pageNo":pageNo,
                "pageSize":pageSize,
                "name":$.trim($("#search-name").val()),
                "owner":$.trim($("#search-owner").val()),
                "startDate":$.trim($("#search-startDate").val()),
                "endDate":$.trim($("#search-endDate").val()),
            },
            type:"get",
            dataType:"json",
            success:function (data) {
                /*
                data：
                我们需要的市场活动信息列表
                [{市场活动1},{市场活动2}] List<Activity> aList
                分页插件需要的，查询出来的总记录数 int total
                {"total":100,"dataList":[{市场活动1}，{市场活动2}]}
                 */
                var html = "";
                //每一个n就是每一个市场活动对象
                $.each(data.dataList,function (i,n) {
                    html += '<tr class="active">'
                    html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>'
                    html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>'
                    html += '<td>'+n.owner+'</td>'
                    html += '<td>'+n.startDate+'</td>'
                    html += '<td>'+n.endDate+'</td>'
                    html += '</tr>'
                })

                $("#activityBody").html(html);

                //计算总页数
				var totalPages = data.total%pageSize==0 ? data.total/pageSize : parseInt(data.total/pageSize)+1;

                //数据处理完毕后，结合分页插件 对前端展现分页相关信息
				$("#activityPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数是在点击分页组件的时候触发的
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});

			}
        })
    }
	
</script>
</head>
<body>

	<input type="hidden" id="hidden-name"/>
	<input type="hidden" id="hidden-owner"/>
	<input type="hidden" id="hidden-startDate"/>
	<input type="hidden" id="hidden-endDate"/>
	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">

								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<!--
					data-dismiss="modal":
						表示关闭模态窗口

					-->
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id"/>
					
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
                            <label for="edit-startDate" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" >
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-descrption" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<!--关于文本域textarea：
									1.一定以标签对出现
									正常状态下标签对要仅仅挨着
									2.textarea虽然是以标签对的形式来呈现的，但是它也是属于表单单元元素范畴
									我们所有的对于textarea的取值和赋值操作，应该使用val()方法（而不是html方法）
									-->
								<textarea class="form-control" rows="3" id="edit-descrption"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
					<!--
					点击创建按钮，观察两个属性值

					data-toggle="modal"
						表示触发该按钮，将会打开一个模态窗口

					data-target="#createActivityModal"
						通过#id打开目标的模态窗口

					现在我们是以属性和属性值的方式写在了button元素中，用来打开模态窗口
					这样问题在于没有办法对按钮的功能进行扩充，
					所以未来实际项目开发对于处罚模态窗口操作一定不能写死在元素中，通过js代码来控制

					-->
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="delete-Btn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">

				<div id="activityPage"></div>

			</div>
			
		</div>
		
	</div>
</body>
</html>