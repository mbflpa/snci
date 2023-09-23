	<cfprocessingdirective pageencoding = "utf-8">
	<!-- Navbar -->
		
		<nav class="main-header navbar navbar-expand navbar-light " style="background-color:#FFC20E;height:56px;box-shadow: 0 7px 14px rgb(0 0 0 / 25%), 0 3px 6px rgb(0 0 0 / 22%) !important" >
			<!-- Left navbar links -->
			<ul class="navbar-nav " style="margin-bottom:16px;display: flex; justify-content: space-between;  width: 100%;">
				<li class="nav-item" style="position:relative;top:5px">
					<a class="nav-link " data-widget="pushmenu" data-enable-remember="true" href="#" role="button"><i class="fas fa-bars"  style="font-size:2rem;"></i></a>
				</li>

				<cfif application.auxsite neq "intranetsistemaspe">
					<div>
						<h3 class="nav-link" style="position:relative;top:5px;color:red"><cfoutput>SERVIDOR: #Ucase(application.auxsite)#</cfoutput></h3>
					</div>
				</cfif>
				
				<li class="nav-item" >
					<a class="nav-link grow-icon" style="position:relative;top:10px" data-widget="fullscreen" href="#" role="button">
						<i class="fas fa-expand-arrows-alt fa-2x"></i>
					</a>
				</li>
			</ul>
		</nav>
		
