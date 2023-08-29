<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>     


<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script language="javascript">
//=============================
//permite digitaçao apenas de valores numéricos
function numericos() {
var tecla = window.event.keyCode;
//permite digitação das teclas numéricas (48 a 57, 96 a 105), Delete e Backspace (8 e 46), TAB (9) e ESC (27)
//if ((tecla != 8) && (tecla != 9) && (tecla != 27) && (tecla != 46)) {
	
	if ((tecla != 46) && ((tecla < 48) || (tecla > 57))) {
		//alert(tecla);
	//  if () {
		event.returnValue = false;
	 // }
	}
//}
}
//================
function ajustar(){
	//return false;
	document.frmObjeto.rdCentraliz.value = 'S';
	document.frmObjeto.submit();
}
//================
</script>
</head>
<body>

<!--- <cfinclude template="valida.cfm"> --->
<cfinclude template="cabecalho.cfm">
<cfoutput> 
<cfquery name="rsAcesso" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_Lotacao, Und_TipoUnidade, Und_Descricao FROM Usuarios INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo WHERE Usu_Login = '#CGI.REMOTE_USER#' 
</cfquery>

<!--- <cfset grupoacesso = "UNIDADES">
#rsAcesso.Usu_GrupoAcesso#<br>
#rsAcesso.Usu_Lotacao#<br>
#rsAcesso.Und_TipoUnidade#<br> --->
<cfset centralSN = "N">
<cfif rsAcesso.Und_TipoUnidade eq 4>
		<cfquery name="rsCentraliza" datasource="#dsn_inspecao#">
		SELECT  Und_Codigo, Und_Centraliza FROM Unidades WHERE Und_Codigo = '#rsAcesso.Usu_Lotacao#'
        </cfquery>
		<cfif rsCentraliza.recordcount gt 0>
		  <cfset centralSN = "S">
		</cfif>
<!--- 		<cfquery name="rsInsp" datasource="#dsn_inspecao#">
		SELECT distinct INP_NumInspecao, Right([INP_NumInspecao],4) AS ano
		FROM Inspecao INNER JOIN Unidades ON INP_Unidade = Und_Codigo 
		INNER JOIN ParecerUnidade ON INP_NumInspecao = Pos_Inspecao AND INP_Unidade = Pos_Unidade
		WHERE (INP_Unidade = '#trim(rsAcesso.Usu_Lotacao)#' OR Pos_Area = '#trim(rsAcesso.Usu_Lotacao)#')
		order by Right([INP_NumInspecao],4) desc
		</cfquery> --->
		<cfquery name="rsInsp" datasource="#dsn_inspecao#">
			SELECT Usu_GrupoAcesso, Usu_Login, INP_NumInspecao, Und_Descricao, Right([INP_NumInspecao],4) AS ano
			FROM Usuarios 
			INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo 
			INNER JOIN Inspecao ON Und_Codigo = INP_Unidade
			INNER JOIN ParecerUnidade ON INP_NumInspecao = Pos_Inspecao AND INP_Unidade = Pos_Unidade
			WHERE Pos_Situacao_Resp Not In (0,11) 
			GROUP BY Usu_GrupoAcesso, Usu_Login, INP_NumInspecao, Und_Descricao
			HAVING Usu_Login = '#CGI.REMOTE_USER#'
			ORDER BY ano desc
		</cfquery>		
<cfelse>
<!---     <cfquery name="rsInsp" datasource="#dsn_inspecao#">
	  SELECT distinct INP_NumInspecao, Right([INP_NumInspecao],4) AS ano 
	  FROM Inspecao 
	  INNER JOIN Unidades ON INP_Unidade = Und_Codigo
	  INNER JOIN ParecerUnidade ON INP_NumInspecao = Pos_Inspecao AND INP_Unidade = Pos_Unidade
	  WHERE (INP_Unidade ='#trim(rsAcesso.Usu_Lotacao)#' OR Pos_Area = '#trim(rsAcesso.Usu_Lotacao)#')
	  order by Right([INP_NumInspecao],4) desc
	</cfquery> --->
		<cfquery name="rsInsp" datasource="#dsn_inspecao#">
			SELECT Usu_GrupoAcesso, Usu_Login, INP_NumInspecao, Und_Descricao, Right([INP_NumInspecao],4) AS ano
			FROM Usuarios 
			INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo 
			INNER JOIN Inspecao ON Und_Codigo = INP_Unidade
			INNER JOIN ParecerUnidade ON INP_NumInspecao = Pos_Inspecao AND INP_Unidade = Pos_Unidade
			WHERE Pos_Situacao_Resp Not In (0,11) 
			GROUP BY Usu_GrupoAcesso, Usu_Login, INP_NumInspecao, Und_Descricao
			HAVING Usu_Login = '#CGI.REMOTE_USER#'
			ORDER BY ano desc
		</cfquery>
</cfif>	

</cfoutput> 

      
	  <form action="Itens_unidades_controle_respostas_matricula.cfm" method="Post" name="frmObjeto">
	 <input name="rdCentraliz" id="rdCentraliz" type="hidden" value="N">
	<table width="600"  align="center" bordercolor="0">
      <tr>
        <td colspan="4">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="4"><p align="center" class="titulo1">Relatório de avaliacao de controle interno </p>
            <p class="exibir"></td>
      </tr>
	 <cfif trim(rsAcesso.Usu_GrupoAcesso) eq "UNIDADES">
	  
	<!---  <cfset gil=gil> --->
      <tr>
        <td>&nbsp;</td>
        <td colspan="3" class="titulo1"><div align="left" class="titulos">Relat&oacute;rios de Verifica&ccedil;&atilde;o de Controle do <cfoutput>#rsAcesso.Und_Descricao#</cfoutput>      </div>
      <tr>
        <td>&nbsp;</td>
        <td colspan="3">      
      <tr>
	   <td width="5">&nbsp;</td>
        <td colspan="3"><span class="exibir"><strong>Responder o  Relat&oacute;rio&nbsp; :&nbsp;&nbsp; </strong></span>
          <!--- <input name="nu_inspecao" type="text" class="form" id="nu_inspecao" tabindex="3" onKeyPress="numericos()" size="14" maxlength="10"> --->
		
			<select name="nu_inspecao" class="form" id="nu_inspecao" onChange="if (this.value != 'N') {document.frmObjeto.rdCentraliz.value = 'N';document.frmObjeto.submit()};"> 
				 <option selected="selected" value="N">---</option> 
			      <cfoutput query="rsInsp">
<!--- 				<!--- 	rsAval.INP_NumInspecao:#rsInsp.INP_NumInspecao#<br> --->
				<cfquery name="rsStatus_011" datasource="#dsn_inspecao#">
				 SELECT Pos_Inspecao FROM ParecerUnidade WHERE (((Pos_Inspecao)='#rsInsp.INP_NumInspecao#') AND ((Pos_Situacao_Resp)=0 Or (Pos_Situacao_Resp)=11)) order by Pos_Inspecao desc
				</cfquery> --->
<!--- 					 <cfif rsStatus_011.recordcount is 0>  
 					<cfquery name="rsLivre" datasource="#dsn_inspecao#">
					   SELECT distinct Pos_Inspecao FROM ParecerUnidade WHERE (Pos_Inspecao = '#rsInsp.INP_NumInspecao#') 
					</cfquery> 
					<cfif rsLivre.recordcount gt 0>  --->
					Usu_GrupoAcesso, Usu_Login, INP_NumInspecao, Und_Descricao, Right([INP_NumInspecao],4) AS ano
						<option value="#INP_NumInspecao#">#INP_NumInspecao#-(#Und_Descricao#)</option>
<!--- 					 </cfif> 
					</cfif>  --->   
				</cfoutput>	
			</select> 
			</td>
</tr>			
	   <tr>
	     <td>&nbsp;</td>
	     <td colspan="3">&nbsp;</td>
       </tr>
	   <tr>
			  <td>&nbsp;</td>
			  <td colspan="3"><hr size="3"></td>
	   </tr>

			<tr>
              <td>&nbsp;</td>
              <td colspan="3">&nbsp;</td>
            </tr>
			
			 <cfif centralSN is "S">
			<cfquery name="rsCDDUnid" datasource="#dsn_inspecao#">
				SELECT DISTINCT Und_Codigo, Und_Descricao, Pos_Inspecao
				FROM (Unidades 
				INNER JOIN ParecerUnidade ON Und_Codigo = Pos_Unidade) 
				INNER JOIN Itens_Verificacao ON (Pos_NumGrupo = Itn_NumGrupo) AND (Pos_NumItem = Itn_NumItem) and (right(Pos_Inspecao,4) = Itn_Ano) and Itn_TipoUnidade = Und_TipoUnidade 
				INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao AND (INP_Modalidade = Itn_Modalidade)
				WHERE (Pos_Situacao_Resp not in (12,13,51)) AND (Und_Centraliza = '#rsAcesso.Usu_Lotacao#') AND (Itn_TipoUnidade = 4)
			  ORDER BY Pos_Inspecao, Und_Descricao
			</cfquery>			
             <tr class="exibir">
               <td>&nbsp;</td>
			   <td colspan="3" class="titulo1"><div align="left" class="titulos">Relat&oacute;rios de Unidades com Distribui&ccedil;&atilde;o Centralizada no <cfoutput>#rsAcesso.Und_Descricao#</cfoutput></div></td>
               
             </tr>
             <tr class="exibir">
               <td>&nbsp;</td>
               <td colspan="3">&nbsp;</td>
             </tr>
             <tr class="exibir">
        <td>&nbsp;</td>
        <td width="143" bordercolor="#CCCCCC"><div align="left"><strong>C&oacute;digo Unidade </strong></div></td>
        <td width="354" bordercolor="#CCCCCC"><div align="left"><strong>Descri&ccedil;&atilde;o</strong></div></td>
        <td width="78" bordercolor="#CCCCCC"><div align="left"><strong>N&ordm; Relat&oacute;rio </strong></div></td>
      </tr>
      
	   <cfset habsn = 'disabled'>
	  <cfoutput query="rsCDDUnid">
		  <cfquery name="rsStatusZero" datasource="#dsn_inspecao#">
			  SELECT Pos_Inspecao, Pos_Unidade FROM ParecerUnidade WHERE Pos_Inspecao = '#rsCDDUnid.Pos_Inspecao#' and (Pos_Situacao_Resp = 0 or Pos_Situacao_Resp = 11)
		  </cfquery>
		  <cfif (rsStatusZero.recordcount lte 0)> 
		  <cfset habsn = ''>
			  <tr class="form">
				<td>&nbsp;</td>
				<td bgcolor="##FFFFBB"><div align="left">#rsCDDUnid.Und_Codigo#</div></td>
				<td bgcolor="##FFFFBB"><div align="left">#Trim(rsCDDUnid.Und_Descricao)#</div></td>
				<cfset nrorelat = #rsCDDUnid.Pos_Inspecao#>
				<td bgcolor="##FFFFBB"><div align="left">#nrorelat#</div></td>
			  </tr>
		  </cfif>
	  </cfoutput>
      
      <tr>
        <td>&nbsp;</td>
        <td colspan="3" bgcolor="#FFFFBB">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
       	
	        <td colspan="3" bgcolor="#FFFFBB">
              <div align="center">
      <input name="ConfirmarCDD" type="button" class="botao" value="Confirmar" onClick="ajustar()" <cfoutput>#habsn#</cfoutput>>
      <!--- <input name="rdCent" type="checkbox" class="form" id="rdCent" onClick="ajustar(this.value)" value="S"> --->
              </div></td>
		
        </tr>
           <tr>
              <td>&nbsp;</td>
              <td colspan="3"><hr></td>
            </tr>
	 
		</cfif>
<!---       <tr>
        <td>&nbsp;</td>
      <td>        <input name="Submit2" type="submit" class="botao" value="Confirmar"></td>
      </tr> ---> 
	  <cfelse> 

	   <tr>
	   <td width="5">&nbsp;</td>
        <td colspan="3"><span class="exibir"><strong>N&ordm; Relat&oacute;rio&nbsp;&nbsp;&nbsp; :&nbsp;&nbsp; </strong></span>
          <!--- <input name="nu_inspecao" type="text" class="form" id="nu_inspecao" tabindex="3" onKeyPress="numericos()" size="14" maxlength="10"> --->
		
		  <input name="nu_inspecao" id="nu_inspecao" type="text" size="14" maxlength="10" tabindex="3" class="form" onKeyPress="numericos()">
	   <tr>

            <td>&nbsp;</td>
        <td colspan="3">&nbsp;</td>
       </tr>
      <tr>
        <td>&nbsp;</td>
      <td colspan="3">        
        <div align="left">
          <input name="Submit2" type="submit" class="botao" value="Confirmar">
        </div></td>
      </tr>
	  <!---  --->
	 </cfif> 
			
      </table>
	  
</form>

<!--- Fim Área de conteúdo --->	 


</body>
</html>