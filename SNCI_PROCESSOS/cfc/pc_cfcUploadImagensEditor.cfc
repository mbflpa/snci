<cfcomponent  >
<cfprocessingdirective pageencoding = "utf-8">	


	<!--- Diretório onde serão armazenadas as imagens --->
<cfset thisDir = expandPath(".")>
<cfset imagensDirAvaliacoes = "#thisDir#\IMAGENS_AVALIACOES" />
<cfset imagensDirFaq = "#thisDir#\IMAGENS_FAQ" />
<!--- fim: Diretório onde serão armazenadas as imagens --->


   
	<cffunction name="uploadImagensAvaliacoes" access="remote"  returntype="boolean" output="false" hint="realiza o upload de imagens inseridas no editor de texto">

   		<cfif directoryExists(imagensDirAvaliacoes)>
        	<cffile action="upload" filefield="file" destination="#imagensDirAvaliacoes#" nameconflict="skip">
        <cfelse>
        	<cfdirectory action="create" directory="#imagensDirAvaliacoes#">
			<cffile action="upload" filefield="file" destination="#imagensDirAvaliacoes#" nameconflict="skip">
        </cfif>
		
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>
		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

		<cfset destino = cffile.serverdirectory & '\Imagem_Aval_id_' & #pc_aval_id# &'_PC' & '#pc_aval_processo#' & '_'  & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>

	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>

		<cfset nomeDaImagem = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

		<cfif FileExists(origem)>
			<cfimage source="#origem#" name="myImage" >  
            <cfif ImageGetHeight(myImage) gt 500 or ImageGetWidth(myImage) gt 500>
				<cfimage source="#origem#" action="resize" width="500" height="" destination="#destino#" overwrite="yes">
				<cffile action="delete" file="#origem#" /> 
			<cfelse>
				<cffile action="rename" source="#origem#" destination="#destino#">
			</cfif>
        </cfif>
		

		<cfset mcuOrgao = "#application.rsUsuarioParametros.pc_org_mcu#">
		<cfif FileExists(destino)>

		    <cftry>
				<cfquery datasource="#application.dsn_processos#" >
						INSERT pc_anexos(pc_anexo_avaliacao_id, pc_anexo_login, pc_anexo_caminho, pc_anexo_nome, pc_anexo_mcu_orgao, pc_anexo_avaliacaoPDF, pc_anexo_enviado )
						VALUES (#pc_aval_id#, '#application.rsUsuarioParametros.pc_usu_login#', '#destino#', '#nomeDaImagem#','#mcuOrgao#', 'N', 1)
				</cfquery>
				<cfcatch type="any">
					<cffile action="delete" file="#destino#" /> 
				</cfcatch>
			</cftry>
			
		</cfif>
		
	
		<cfreturn true />
    </cffunction>


	<cffunction name="uploadImagensFaq" access="remote"  returntype="boolean" output="false" hint="realiza o upload de imagens inseridas no editor de texto">

   		<cfif directoryExists(imagensDirFAQ)>
        	<cffile action="upload" filefield="file" destination="#imagensDirFaq#" nameconflict="skip">
        <cfelse>
        	<cfdirectory action="create" directory="#imagensDirFaq#">
			<cffile action="upload" filefield="file" destination="#imagensDirFaq#" nameconflict="skip">
        </cfif>
		
		
		<cfset data = DateFormat(now(),'DD-MM-YYYY') & '-' & TimeFormat(Now(),'HH') & 'h' & TimeFormat(Now(),'MM') & 'min' & TimeFormat(Now(),'ss.SSSSS') & 's'>
		<cfset origem = cffile.serverdirectory & '\' & cffile.serverfile>

		<cfset destino = cffile.serverdirectory & '\FAQ_ID_' & #pc_imagem_tipo_id# & '_' & '#application.rsUsuarioParametros.pc_usu_matricula#'  & '_' & data  & '.' & '#cffile.clientFileExt#'>

	    <cfobject component = "pc_cfcAvaliacoes" name = "tamanhoArquivo">
		<cfinvoke component="#tamanhoArquivo#" method="renderFileSize" returnVariable="tamanhoDoArquivo" size ='#cffile.fileSize#' type='bytes'>

		<cfset nomeDaImagem = '#cffile.clientFileName#'  & '.' & '#cffile.clientFileExt#'>

		<cfif FileExists(origem)>
			<cfimage source="#origem#" name="myImage" >  
            <cfif ImageGetHeight(myImage) gt 500 or ImageGetWidth(myImage) gt 500>
				<cfimage source="#origem#" action="resize" width="500" height="" destination="#destino#" overwrite="yes">
				<cffile action="delete" file="#origem#" /> 
			<cfelse>
				<cffile action="rename" source="#origem#" destination="#destino#">
			</cfif>
        </cfif>
		  

		
		<cfif FileExists(destino)>
		    <cftry>
				<cfquery datasource="#application.dsn_processos#" >
						INSERT pc_imagens(pc_imagem_tipo, pc_imagem_tipo_id, pc_imagem_caminho, pc_imagem_nome, pc_imagem_dataHora, pc_imagem_login)
						VALUES ('faq',#pc_imagem_tipo_id#, '#destino#', '#nomeDaImagem#',<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp"> ,'#application.rsUsuarioParametros.pc_usu_login#')
				</cfquery>
				<cfcatch type="any">
					<cffile action="delete" file="#destino#" /> 
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn true />
    </cffunction>
	



    
    <cffunction name="renderFileSize" access="public" output="false" hint="transforma a forma de apresentação do tamanho dos anexos">
		<cfargument name="size" type="numeric" required="true" hint="File size to be rendered" />
		<cfargument name="type" type="string" required="true" default="bytes" />
		
		<cfscript>
			local.newsize = ARGUMENTS.size;
			local.filetype = ARGUMENTS.type;
			do{
				local.newsize = (local.newsize / 1024);
				if(local.filetype IS 'bytes')local.filetype = 'KB';
				else if(local.filetype IS 'KB')local.filetype = 'MB';
				else if(local.filetype IS 'MB')local.filetype = 'GB';
				else if(local.filetype IS 'GB')local.filetype = 'TB';
			}while((local.newsize GT 1024) AND (local.filetype IS NOT 'TB'));
			local.filesize = REMatchNoCase('[(0-9)]{0,}(\.[(0-9)]{0,2})',local.newsize);
			if(arrayLen(local.filesize))return local.filesize[1] & ' ' & local.filetype;
			else return local.newsize & ' ' & local.filetype;
			return local;
		</cfscript>
	</cffunction>






	<cffunction name="browserImagensEditorFaq" returntype="any" access="remote"  hint="transforma a forma de apresentação do tamanho dos anexos">
		<cfargument name="pc_imagem_tipo_id" type="  " required="true" default="bytes" />
		
		<style>
			#tabImagens_wrapper #tabImagens_paginate ul.pagination {
				justify-content: center!important;
			}

		</style>
		<div class="card-body" style="border: solid 3px #ffD400;">
					
				<cfif directoryExists(imagensDirFaq)>
					<cfdirectory action="list" directory="#imagensDirFaq#" recurse="false" listinfo="name" name="myList" sort = "datelastmodified Desc" filter="*.png|*.jpg|*.jpeg|*.gif">
				<cfelse>
					<cfdirectory action="create" directory="#imagensDirFaq#">
					<cfdirectory action="list" directory="#imagensDirFaq#" recurse="false" listinfo="name" name="myList" sort = "datelastmodified Desc" filter="*.png|*.jpg|*.jpeg|*.gif">
				</cfif>

				 
				<cfif '#myList.RecordCount#'eq 0> 
					<H4>Nenhuma Imagem no servidor.</H4>
				<cfelse>
					<table id="tabImagens" class="table  " style="background: none;border:none;width:100%">
						<thead >
							<tr style="background: none;border:none">
								<th style="background: none;border:none"></th>
							</tr>
						</thead>
						
						<tbody class="grid-container" >
							<cfloop query="myList" >

								<cfset dir = 'IMAGENS_FAQ/#myList.name#' >
								<cfimage source="#dir#" name="myImage">
								<cfset info=ImageInfo(myImage)>
								<cfset larguraImg = "#info.width#">
								<cfset alturaImg = "#info.height#">  
								<cfset ImageSetAntialiasing(myImage,"on")>
								<cfset ImageScaleToFit(myImage,260,130)>
								<cfquery name="rsImagens" datasource="#application.dsn_processos#">
									SELECT pc_imagens.* from pc_imagens
									WHERE pc_imagem_caminho like '%#myList.name#' and 
								</cfquery>
								
								<tr style="width:270px;border:none">

									<td style="background: none;border:none">

										<section class="content" >
											<div id="cartaoPerfil" style="width:270px;border:none" >
												<!-- small card -->
												<div class="small-box " style="font-weight: normal;background:color: #fff;font-weight: normal;">
													
													<div align="center" class="divImagem" style="cursor:pointer;text-align:center;"  >
														<cfimage alt="#myList.name#" source="#myImage#" style="margin-top:5px" action="WriteToBrowser" onclick="InsereImagem('cfc/#info.source#', #larguraImg#)">
													</div>

													<div class="small-box-footer" style="background:none!important;"  >
														<div align="center"  class="card-header" style="width:250px;border-bottom:none; font-weight: normal!important;padding:5px">
															<span style="font-size:10px;color:#000"><strong><cfoutput>#rsImagens.pc_imagem_nome# (#info.colormodel.pixel_size#px; #info.width#X#info.height#)</cfoutput></strong></span>
														</div>
														<div style="display:flex;justify-content: space-around;color:red!important;" >
															<i  class="fas fa-trash-alt efeito-grow"  onMouseOver="this.style.color='#f6d12f'" onMouseOut="this.style.color='red'" style="color:red;cursor: pointer;z-index:100;font-size:16px" onclick="excluirImagem(<cfoutput>#rsImagens.pc_imagem_id#</cfoutput>)" data-toggle="tooltip"  tilte="Excluir" ></i>
														</div>
													</div>
												</div>
											</div>
										</section>

									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</cfif>
		</div>


		<script language="JavaScript">
			$(function () {
				$("#tabImagens").DataTable({
					"destroy": true,
					"ordering": false,
				    "stateSave": false,
					"responsive": true, 
					"lengthChange": true, 
					"sScrollY": "32em",
					"autoWidth":true,
					"dom": 
							"<'row'<'col-sm-12 text-right'f>>" +
							"<'row'<'col-sm-4'l><'col-sm-4'p><'col-sm-4 text-right'i>>" +
							"<'row'<'col-sm-12'tr>>" ,
					"lengthMenu": [
						[10, 25, 50, -1],
						[10, 25, 50, 'All'],
					]
				})
					
			});



		</script>

   </cffunction>




   	<cffunction name="delImagem"   access="remote" returntype="boolean">
		<cfargument name="pc_imagem_id" type="numeric" required="true" default=""/>

		<cfquery datasource="#application.dsn_processos#" name="rsPc_imagens"> 
			SELECT pc_imagens.*   FROM  pc_imagens
			WHERE pc_imagem_id = <cfquerypara value="#arguments.pc_imagem_id#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif FileExists(rsPc_imagens.pc_imagem_caminho)>
			<cffile action = "delete" File = "#rsPc_imagens.pc_imagem_caminho#">
		</cfif>

		<cfquery datasource="#application.dsn_processos#">
			DELETE FROM pc_imagens
			WHERE pc_imagem_id = <cfquerypara value="#arguments.pc_imagem_id#" cfsqltype="cf_sql_integer">
		</cfquery> 	


		<cfreturn true />
	</cffunction>


	<cffunction name="getThumbnail" returnType="any" output="false" hint="Get a thumbnail of the first page of a PDF file. - Não utilizando no SNCI">
		<cfargument name="url" type="string" required="true">
		<cfargument name="scale" type="numeric" required="false" default="25">
		
		<cfset var pdfdata = "">
		<cfset var prefix = replace(createUUID(),"-","_","all")>
		<cfset var myimage = "">
		
		<!--- Verificar se o arquivo PDF existe --->
		<cfif NOT FileExists(arguments.url)>
			<cfthrow message="O arquivo PDF especificado não existe." detail="URL: #arguments.url#">
		</cfif>
		
		<!--- Depurar o URL --->
		<cfoutput>URL do PDF: #arguments.url#</cfoutput>
		
		<!--- make the pdf --->
		<cfdocument src="#arguments.url#" name="pdfdata" format="pdf" />
		
		<!--- write out the image --->
		<cfpdf source="pdfdata" pages="1" action="thumbnail" destination="." format="jpg" overwrite="true" resolution="high" scale="#arguments.scale#" imagePrefix="#prefix#">
		
		<!--- read it in --->
		<cfset myimage = imageNew(expandPath('./#prefix#_page_1.jpg'))>
		
		<!--- clean it up --->
		<cffile action="delete" file="#expandPath('./#prefix#_page_1.jpg')#">

		<!--- IMPLEMENTAR DA SEGUINTE FORMA
		<cfset myimage = getThumbnail(pc_anexo_caminho,10)> 
		<a href="pc_Anexos.cfm?arquivo=<cfoutput>#caminho#</cfoutput>" target="_blank">
			<cfimage action="writeToBrowser" source="#myimage#">
		</a>
		--->
		
		<cfreturn myimage> 
	</cffunction>



</cfcomponent>