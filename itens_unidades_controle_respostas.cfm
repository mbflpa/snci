<cfprocessingdirective pageEncoding ="utf-8"/>
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT Usu_GrupoAcesso, Usu_Lotacao, Und_TipoUnidade, Und_Descricao, Und_Centraliza FROM Usuarios INNER JOIN Unidades ON Usu_Lotacao = Und_Codigo WHERE Usu_Login = '#CGI.REMOTE_USER#' 
</cfquery>

<cfset AC_em_CDD_SN = "N">

<cfif (trim(qUsuario.Und_Centraliza) neq "")>
	   <cfset AC_em_CDD_SN = "S">
</cfif>
<!--- <cfoutput>#AC_em_CDD_SN#</cfoutput>
<cfset gil=gil> --->

<cfset area = 'sins'>

<cfset total=0>

<cfif IsDefined("URL.Ninsp")>
<!---<cfset url.dtInicio = url.DtInic>--->
  <cfset FORM.nu_inspecao = url.Ninsp>
<!--- <cfelse> --->
<!---<cfset url.dtInicio = createdate(right(form.dtinic,4), mid(form.dtinic,4,2), left(form.dtinic,2))>--->
</cfif>

<cfif IsDefined("url.numero")>
    <cfset FORM.nu_inspecao = url.numero>
</cfif>

<cfquery name="qVerificaData" datasource="#dsn_inspecao#">
	SELECT INP_DtInicInspecao, INP_DtEncerramento, INP_Unidade FROM Inspecao WHERE INP_NumInspecao = '#FORM.nu_inspecao#'
</cfquery>

<cfif form.rdCentraliz eq "S">
	    <cfif qUsuario.Und_TipoUnidade is 4>
		    <cfquery name="rsCDDUnid" datasource="#dsn_inspecao#">
				SELECT DISTINCT Pos_Inspecao, Pos_Unidade, Und_Descricao
				FROM (Itens_Verificacao 
				INNER JOIN ParecerUnidade ON (right([Pos_Inspecao], 4) = Itn_Ano) and (Itn_NumGrupo = Pos_NumGrupo) AND (Itn_NumItem = Pos_NumItem)) 
				INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao  AND (INP_Modalidade = Itn_Modalidade)
				INNER JOIN Unidades ON Pos_Unidade = Und_Codigo and Itn_TipoUnidade = Und_TipoUnidade
				WHERE (((Und_Centraliza)='#qUsuario.Usu_Lotacao#') AND ((Itn_TipoUnidade)=4) AND ((Pos_Situacao_Resp)<>12 And (Pos_Situacao_Resp)<>13 And (Pos_Situacao_Resp)<>51))
				ORDER BY Pos_Inspecao
			</cfquery>
			<cfset unids = "">
			<cfoutput query="rsCDDUnid">
                 <cfquery name="rsStatusZero" datasource="#dsn_inspecao#">
			        SELECT Pos_Inspecao, Pos_Unidade FROM ParecerUnidade WHERE Pos_Inspecao = '#rsCDDUnid.Pos_Inspecao#' and (Pos_Situacao_Resp = 0 or Pos_Situacao_Resp = 11)
		         </cfquery>
				 <cfif (rsStatusZero.recordcount lte 0)>
					   <cfif unids is "">
						 <cfset unids = "Pos_Unidade = " & trim(rsCDDUnid.Pos_Unidade)>
					   <cfelse>
						 <cfset unids = unids & " OR Pos_Unidade = " & trim(rsCDDUnid.Pos_Unidade)>
					   </cfif>
				  </cfif>
			</cfoutput>
			<cfquery name="rsItem" datasource="#dsn_inspecao#">
				SELECT DATEDIFF(dd,Pos_DtPosic,GETDATE()) as dias, INP_DtInicInspecao, INP_DTFIMINSPECAO, INP_DTENCERRAMENTO, INP_TNCClassificacao, Pos_Unidade, INP_Responsavel, Und_Descricao, Pos_Inspecao, Pos_Parecer, Pos_DtPosic, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant, POS_DTPREV_SOLUCAO, Pos_NumGrupo, Pos_NumItem, Pos_dtultatu, Itn_Descricao, Itn_ValorDeclarado, Grp_Descricao, Pos_Situacao_Resp, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto, Pos_Area,Pos_DtPosic,Pos_DtPrev_Solucao
				FROM ((Inspecao 
				INNER JOIN (ParecerUnidade 
				INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
				ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
				INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
				INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao 
				ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) 
				ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND 
				(Und_TipoUnidade = Itn_TipoUnidade)
				WHERE (#unids#) and Pos_Situacao_Resp not in (9,12,13,51) and Itn_TipoUnidade = 4 and left(Pos_Unidade,2) = left(Pos_Area,2)
				order by Und_Descricao, INP_DtInicInspecao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem 
		   </cfquery>
		<cfelse>
		   <cfquery name="rsItem" datasource="#dsn_inspecao#">
				SELECT DATEDIFF(dd,Pos_DtPosic,GETDATE()) as dias, INP_DtInicInspecao, INP_TNCCLASSIFICACAO, Pos_Unidade, INP_Responsavel, Und_Descricao, Pos_Inspecao, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, Pos_dtultatu, Itn_Descricao, Itn_ValorDeclarado, Grp_Descricao, Itn_ValorDeclarado, Pos_Situacao_Resp, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto, Pos_Area,Pos_DtPosic,Pos_DtPrev_Solucao
				FROM ((Inspecao 
				INNER JOIN (ParecerUnidade 
				INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
				ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
				INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
				INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao 
				ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) 
				ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND 
				(Und_TipoUnidade = Itn_TipoUnidade)
				WHERE (Pos_Inspecao='#FORM.nu_inspecao#') and Pos_Situacao_Resp not in (9,12,13,51) and left(Pos_Unidade,2) = left(Pos_Area,2)
				order by INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		   </cfquery>
		</cfif>
<cfelseif (qUsuario.Und_TipoUnidade eq 9 OR qUsuario.Und_TipoUnidade eq 30) and (AC_em_CDD_SN eq "S")>
		<cfquery name="rsItem" datasource="#dsn_inspecao#">
			SELECT DATEDIFF(dd,Pos_DtPosic,GETDATE()) as dias, INP_DtInicInspecao, Pos_Unidade, INP_Responsavel, INP_TNCCLASSIFICACAO, Und_Descricao, Pos_Inspecao, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, Pos_dtultatu, Itn_Descricao, Itn_ValorDeclarado, Grp_Descricao, Pos_Situacao_Resp, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto, Pos_Area,Pos_DtPosic,Pos_DtPrev_Solucao
			FROM ((Inspecao 
			INNER JOIN (ParecerUnidade 
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
			ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
			INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
			INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao 
			ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) 
			ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND 
			(Und_TipoUnidade = Itn_TipoUnidade)
			
			WHERE (Pos_Inspecao='#FORM.nu_inspecao#') and (Pos_Unidade='#qUsuario.Usu_Lotacao#') and (Pos_Situacao_Resp not in (9,12,13,51)) AND (Itn_TipoUnidade <> 4) and left(Pos_Unidade,2) = left(Pos_Area,2)
			order by INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
<cfelseif (qUsuario.Und_TipoUnidade eq 9 OR qUsuario.Und_TipoUnidade eq 30) and (AC_em_CDD_SN eq "N")>
		<cfquery name="rsItem" datasource="#dsn_inspecao#">
			SELECT DATEDIFF(dd,Pos_DtPosic,GETDATE()) as dias, INP_DtInicInspecao, Pos_Unidade, INP_Responsavel, INP_TNCCLASSIFICACAO, Und_Descricao, Pos_Inspecao, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, Pos_dtultatu, Itn_Descricao, Grp_Descricao, Itn_ValorDeclarado, Pos_Situacao_Resp, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto, Pos_Area,Pos_DtPosic,Pos_DtPrev_Solucao
			FROM ((Inspecao 
			INNER JOIN (ParecerUnidade 
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
			ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
			INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
			INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao 
			ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) 
			ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND 
			(Und_TipoUnidade = Itn_TipoUnidade)
			
			WHERE (Pos_Inspecao='#FORM.nu_inspecao#') and (Pos_Situacao_Resp not in (9,12,13,51)) and left(trim('#qUsuario.Usu_Lotacao#'),2) = left(Pos_Area,2)
			order by INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
<cfelse>
		<cfquery name="rsItem" datasource="#dsn_inspecao#">
			SELECT DATEDIFF(dd,Pos_DtPosic,GETDATE()) as dias, INP_DtInicInspecao, Pos_Unidade, INP_Responsavel, INP_TNCCLASSIFICACAO, Und_Descricao, Pos_Inspecao, Pos_Parecer, Pos_NumGrupo, Pos_NumItem, Pos_dtultatu, Itn_Descricao, Grp_Descricao, Itn_ValorDeclarado, Pos_Situacao_Resp, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_ClassificacaoPonto, Pos_Area,Pos_DtPosic,Pos_DtPrev_Solucao
			FROM ((Inspecao 
			INNER JOIN (ParecerUnidade 
			INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo) 
			ON (INP_NumInspecao = Pos_Inspecao) AND (INP_Unidade = Pos_Unidade)) 
			INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
			INNER JOIN (Itens_Verificacao INNER JOIN Grupos_Verificacao 
			ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)) 
			ON (right(Pos_Inspecao,4) = Itn_Ano) and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) AND (INP_Modalidade = Itn_Modalidade) AND 
			(Und_TipoUnidade = Itn_TipoUnidade)
			WHERE (Pos_Inspecao='#FORM.nu_inspecao#') and (Pos_Situacao_Resp not in (9,12,13,51)) and left(Pos_Unidade,2) = left(Pos_Area,2)
			order by INP_DtInicInspecao, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
		</cfquery>
</cfif>

 <cfif rsItem.recordCount eq 0>
	<html>
	<head>
	<title>Sistema Nacional de Controle Interno</title>
	<link href="CSS.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<cfinclude template="cabecalho.cfm">
	<table border="0">
	<tr>
	<td>
	   Nãoo há ítens pendentes para este Relatório de Avaliação de Controle Interno.
	<br><br>

	<input name="" value="fechar" type="button" onClick="self.close(); ">
	</td>
	</tr>
	</table>
	</body>
	</html>
	<cfabort>
</cfif>    


<cfquery name="qInspetor" datasource="#dsn_inspecao#">
  SELECT IPT_MatricInspetor, Fun_Nome
  FROM Inspetor_Inspecao INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric AND
  IPT_MatricInspetor = Fun_Matric
  WHERE (IPT_NumInspecao = '#FORM.nu_inspecao#')
</cfquery>

<cfquery name="qVerificaRevisao" datasource="#dsn_inspecao#">
  SELECT Pos_Inspecao, Pos_Situacao_Resp
  FROM ParecerUnidade
  WHERE Pos_Inspecao = '#FORM.nu_inspecao#' AND ((Pos_Situacao_Resp = 0) OR (Pos_Situacao_Resp = 11))
</cfquery>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfset DataDia = DateFormat(now(),'DD/MM/YYYY')>

<cfset DtEncerramento = DateFormat(qVerificaData.INP_DtEncerramento,'DD/MM/YYYY')>


<!--- Verifica��o para acessar o relatorio de inspe��o em diferentes perfis --->

<cfset Vacesse = 0>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES') or (Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES')>

   <cfset vAcesse = 1>

</cfif>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'UNIDADES') and (qVerificaRevisao.recordcount eq 0)>

   <cfset vAcesse = 1>

</cfif>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES') and (DtEncerramento eq DataDia) and (qVerificaRevisao.recordcount neq 0)>

  <cfset vAcesse = 1>

</cfif>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'INSPETORES') and (qVerificaRevisao.recordcount eq 0)>

  <cfset vAcesse = 1>

</cfif>

<!--- <cfif vAcesse eq 1> --->

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
 <script language="javascript">
	function voltar(){
        document.formvolta.submit();
     }
 </script>
  <cfquery name="rsSta" datasource="#dsn_inspecao#">
   SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto WHERE STO_Status='A'
 </cfquery>
 
 <cfoutput query="rsSta">
 <div id="#rsSta.STO_Sigla#" style="position:absolute; z-index:1; visibility: hidden; background-color: #rsSta.STO_Cor#; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;"><font size="1" face="Verdana" color="000000">#rsSta.STO_Conceito#</font></div>
</cfoutput>
</head>
<body>
<script language="JavaScript">
//detectando navegador
sAgent = navigator.userAgent;
bIsIE = sAgent.indexOf("MSIE") > -1;
bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

//setando as variaveis de controle de eventos do mouse
var xmouse = 0;
var ymouse = 0;
document.onmousemove = MouseMove;

//funcoes de controle de eventos do mouse:
function MouseMove(e){
 if (e) { MousePos(e); } else { MousePos();}
}

function MousePos(e) {
 if (bIsNav){
  xmouse = e.pageX;
  ymouse = e.pageY;
 }
 if (bIsIE) {
  xmouse = document.body.scrollLeft + event.x;
  ymouse = document.body.scrollTop + event.y;
 }
}

//funcao que mostra e esconde o hint
function Hint(objNome, action){
 //action = 1 -> Esconder
 //action = 2 -> Mover

 if (bIsIE) {
  objHint = document.all[objNome];
 }
 if (bIsNav) {
  objHint = document.getElementById(objNome);
  event = objHint;
 }

 switch (action){
  case 1: //Esconder
   objHint.style.visibility = "hidden";
   break;
  case 2: //Mover
   objHint.style.visibility = "visible";
   objHint.style.left = xmouse + 15;
   objHint.style.top = ymouse + 15;
   break;
 }

}
</script>
<cfinclude template="cabecalho.cfm">

<table width="98%" height="45%">

<table width="95%" border="0" align="center">

	<br><br>
<cfif form.rdCentraliz neq "S">
	 <cfset Num_Insp = Left(rsItem.Pos_Inspecao,2) & '.' & Mid(rsItem.Pos_Inspecao,3,4) & '/' & Right(rsItem.Pos_Inspecao,4)>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Nº Avaliação</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#Num_Insp#</span></cfoutput></td>
	  <td bgcolor="eeeeee"><span class="titulos">Início: <cfoutput><span class="titulosClaro">#DateFormat(rsItem.INP_DtInicInspecao,"dd/mm/yyyy")#</span></cfoutput></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td align="center" bgcolor="eeeeee" class="titulos">Imprimir</td>
	</tr>
	<tr>
	  <td bgcolor="eeeeee"><span class="titulos">Unidade</span></td>
	  <td bgcolor="f7f7f7"><cfoutput><span class="titulosClaro">#rsItem.Und_Descricao#</span></cfoutput></td>
	  <td bgcolor="eeeeee"><span class="titulos">Responsável: <cfoutput><span class="titulosClaro">#rsItem.INP_Responsavel#</span></cfoutput></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td bgcolor="eeeeee"><span class="titulos"></span></td>
	  <td align="center" bgcolor="f7f7f7">
	    <form action="GeraRelatorio/gerador/dsp/relatorioHTML.cfm" name="frmHtml" method="post" target="_blank">
	      <img src="icones/relatorio.jpg" height="48" alt="Visualizar relatório em HTML" border="0" onClick="forms[0].submit()" onMouseOver="this.style.cursor='hand';" onMouseOut="this.style.cursor='pointer';">
		  <input type="hidden" name="id" value="<cfoutput>#FORM.nu_inspecao#</cfoutput>">
	    </form>
	  </td>
	 </tr>
	<tr>
	<td bgcolor="eeeeee">
	  <cfif qInspetor.RecordCount lt 2>
	    <span class="titulos">Inspetor</span>
	  <cfelse>
	    <span class="titulos">Inspetores</span>
	  </cfif>
	  </td>
	  <td bgcolor="f7f7f7">
		<table width="500" border="0">
			<cfloop query="qInspetor">
			<tr>
			<td><strong class="titulosClaro">-&nbsp;<cfoutput>#qInspetor.Fun_Nome#</cfoutput></span></td>
			</tr>
			</cfloop>
		</table>
	  </td>
	 </tr>

  <tr class="exibir">
    <td width="5%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Status</div></td>
    <td width="3%" bgcolor="eeeeee" class="titulos"><div align="center">Grupo</div></td>
    <td width="4%" bgcolor="eeeeee" class="titulos"><div align="center">Item</div></td>
	<td width="1%" bgcolor="eeeeee" class="titulos"></td>
	<td width="3%" align="center" bgcolor="eeeeee" class="exibir"><strong>Posição</strong></td>
    <td width="4%" align="center" bgcolor="eeeeee" class="exibir"><strong>Prev_Solução</strong></td>
	<td width="1%" bgcolor="eeeeee" class="titulos"></td>
	<td width="3%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Classificação</div></td>
  </tr>
 <cfelse>
   <tr>
    <td height="20%" colspan="11" class="titulosClaro"><div align="center"><cfoutput><div align="left">Qt. Itens: #rsItem.recordCount#</div></cfoutput></div></td>
  </tr>
  <tr class="titulosClaro">
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Status</div></td>
	<td width="2%" bgcolor="eeeeee" class="exibir"><div align="center">Posição</div></td>
    <td width="3%" bgcolor="eeeeee" class="exibir"><div align="center">Previsão</div></td>
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Início</div></td>
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Fim</div></td>
	<td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Envio Ponto</div></td>
    <td width="12%" bgcolor="eeeeee" class="exibir"><div align="center">Nome da Unidade</div></td>
    <td width="5%" bgcolor="eeeeee" class="exibir"><div align="center">Relatório</div></td>
    <td width="17%" bgcolor="eeeeee" class="exibir"><div align="center">Grupo</div></td>
    <td width="20%" bgcolor="eeeeee" class="exibir"><div align="center">Item</div></td>
	<td width="5%" bgcolor="eeeeee" class="titulos" height="16"><div align="center">Classificação</div></td>
  </tr>
</cfif>
  <cfset numlinhas = int(rsItem.recordCount)>

 <cfoutput query="rsItem"> 
	<cfset auxtelaprev = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')>
	<cfquery name="rsReincide" datasource="#dsn_inspecao#">
		SELECT RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem 
		FROM Resultado_Inspecao 
		WHERE RIP_NumInspecao = '#Pos_Inspecao#' and RIP_NumGrupo = #Pos_NumGrupo# and RIP_NumItem = #Pos_NumItem# AND RIP_ReincGrupo <> 0
	</cfquery>
   <cfset resp = rsItem.Pos_Situacao_Resp>
   <cfset btnSN = 'N'>
   <cfif Pos_Situacao_Resp eq 4 or Pos_Situacao_Resp eq 16>
		<cfquery name="rsAnd" datasource="#dsn_inspecao#">
		SELECT Pos_Unidade 
		FROM Andamento INNER JOIN ParecerUnidade ON (Pos_Situacao_Resp = And_Situacao_Resp) AND (Pos_DtPosic = And_DtPosic) AND (Pos_NumItem = And_NumItem) AND (Pos_NumGrupo = And_NumGrupo) AND (Pos_Inspecao = And_NumInspecao) AND (And_Unidade = Pos_Unidade) 
		WHERE (((Pos_Situacao_Resp)=#Pos_Situacao_Resp#) AND ((And_username) Like 'rotina%')) AND (And_Unidade = '#Pos_Unidade#') and (And_NumInspecao = '#Pos_Inspecao#') and (And_NumGrupo = #Pos_NumGrupo#) and (And_NumItem = #Pos_NumItem#) and left(Pos_Unidade,2) = left(Pos_Area,2)
		</cfquery>	
		<cfif rsAnd.recordcount gt 0>
		   <cfset btnSN = 'S'>
		</cfif>
	  </cfif>

	<cfif ((resp eq 1 and dias gt 2) and (resp eq 17 and dias gt 2) and (resp eq 19))>
			 <cfset numlinhas = int(numlinhas) -1>
	<cfelse>

   <cfif form.rdCentraliz neq "S">
	<tr bgcolor="f7f7f7" class="exibir" align="center">
		<cfif btnSN eq 'N'>
			<td width="6%" height="16" bgcolor="#STO_Cor#"><div align="center">
				<a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&rdCentraliz=#form.rdCentraliz#&vlrdec=#rsItem.Itn_ValorDeclarado#&perdaprzsn=#btnSN#&posarea=#rsItem.Pos_Area#"  class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a></div>
			</td> 
		<cfelse>
			<td width="6%" height="16" bgcolor="A80643"><div align="center">
				<a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&rdCentraliz=#form.rdCentraliz#&vlrdec=#rsItem.Itn_ValorDeclarado#&perdaprzsn=#btnSN#&posarea=#rsItem.Pos_Area#"  class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>PERDA PRAZO UNIDADE</strong></a></div>
			</td> 
		</cfif>
		<cfset numReincInsp = ''>
		<cfif rsReincide.recordcount gt 0>
		      <cfset numReincInsp = 'item REINCIDENTE (' & Left(rsReincide.RIP_ReincInspecao,2) & '.' & Mid(rsReincide.RIP_ReincInspecao,3,4) & '/' & Right(rsReincide.RIP_ReincInspecao,4) & ')'>
		</cfif>
		<td width="15%" height="16"><div align="left"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
        <td width="25%" height="16"><div align="left"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div><td>
		<cfset auxtela = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
		<td width="3%"><div align="center">#auxtela#</div></td>
		<td width="3%"><div align="center">#auxtelaprev#</div></td>
		<td width="11%" class="red_titulo">#numReincInsp#</td>
		<cfset auxs = rsItem.Pos_ClassificacaoPonto>
	    <td width="3%" height="16"><div align="center"><div align="center">#auxs#</div></td>
    </tr> 
	
	<cfelse>
       <tr class="exibir">
		<cfif btnSN eq 'N'>
		<td width="5%" bgcolor="#STO_Cor#"><div align="center">
		<a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&rdCentraliz=#form.rdCentraliz#&vlrdec=#rsItem.Itn_ValorDeclarado#&perdaprzsn=#btnSN#&posarea=#rsItem.Pos_Area#"  class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a>		</div>
	 	</td>
		<cfelse>
		<td width="5%" height="26" bgcolor="A80643"><div align="center">
         <a href="itens_unidades_controle_respostas1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&rdCentraliz=#form.rdCentraliz#&vlrdec=#rsItem.Itn_ValorDeclarado#&perdaprzsn=#btnSN#&posarea=#rsItem.Pos_Area#"  class="exibir" onMouseMove="Hint('#STO_Sigla#',2)" onMouseOut="Hint('#STO_Sigla#',1)"><strong>PERDA PRAZO UNIDADE</strong></a>		</div>
		 </td> 
		</cfif>
      <cfset auxtela = DateFormat(rsItem.Pos_DtPosic,'DD/MM/YYYY')>
	  <td width="5%"><div align="center">#auxtela#</div></td>
	  <!--- <cfset auxtela = DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')> --->
	  <td width="5%"><div align="center">#auxtelaprev#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')>
      <td width="5%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')>
      <td width="5%"><div align="center">#auxtela#</div></td>
	  <cfset auxtela = DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')>
	  <td width="5%"><div align="center">#auxtela#</div></td>
      <td width="12%"><div align="center">#rsItem.Und_Descricao#</div></td>
	  <cfset auxtela = rsItem.Pos_Inspecao>
      <td width="5%"><div align="center">#auxtela#</div></td>
      <td width="17%"><div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> - #rsItem.Grp_Descricao#</div></td>
      <td width="20%"><div align="justify"><strong>#rsItem.Pos_NumItem#</strong> - &nbsp;#rsItem.Itn_Descricao#</div></td>
	  <cfset auxs = rsItem.Pos_ClassificacaoPonto>
	  <td width="4%"><div align="center"><div align="center">#auxs#</div></td>
	 <!--- </tr> --->
	</cfif>

	</tr>
	 </cfif>
</cfoutput>
</table>

<!--- Fim a�rea de conteudo --->
	  </td>
  </tr>
</table>
<table width="90%" border="0" align="center">

	<tr>
		<td colspan="5" class="titulos"><div align="center">Quantidade de pontos do Relatório de Avaliação de Controle Interno com Situação Encontrada: <font class="red_titulo"><cfoutput>#numlinhas#</cfoutput></font></div></td>
	</tr>
<!---           <tr>
            <td colspan="4"><div align="center"><span class="exibir">Classifica&ccedil;&atilde;o da Unidade:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span class="exibir"><strong><cfoutput>#rsItem.INP_TNCClassificacao#</cfoutput></strong></span></div></td>
          </tr>	 --->
	<!--- Fim da Classifica��o --->
  <tr><td width="72">&nbsp;</td></tr>
   <tr class="exibir" align="center">
       <td height="26" colspan="5" align="center"><input type="button" class="botao"  onClick="voltar()" value="Voltar"></td>
   </tr>
</table> 
    <form name="formvolta" method="post" action="Itens_unidades_controle_respostas_ref.cfm?flush=true">
    </form>
</body>
</html>




