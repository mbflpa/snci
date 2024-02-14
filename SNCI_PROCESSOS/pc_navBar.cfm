	<cfprocessingdirective pageencoding = "utf-8">
	<!-- Navbar -->
		
		<nav class="main-header navbar navbar-expand navbar-light shadow-sm" style="background-color:#FFC20E;height:56px;" >
			<!-- Left navbar links -->
			<ul class="navbar-nav " style="margin-bottom:16px;display: flex; justify-content: space-between;  width: 100%;">
				<li class="nav-item" style="position:relative;top:5px">
					<a class="nav-link " data-widget="pushmenu" data-enable-remember="true" href="#" role="button"><i class="fas fa-bars"  style="font-size:2rem;"></i></a>
				</li>

				 <cfif FindNoCase("homologacaope", application.auxsite) or FindNoCase("desenvolvimentope", application.auxsite) or FindNoCase("localhost", application.auxsite)>
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
		
