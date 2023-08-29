<cfprocessingdirective pageEncoding ="utf-8"/>  
<!--- <cfdump var="#form#"> <cfdump var="#session#"> --->
<!---  <cfdump var="#url#">  --->
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
</cfif>           
<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_GrupoAcesso, Usu_Matricula, Usu_Email 
	from usuarios 
	where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
<cfif (grpacesso neq 'GESTORES') and (grpacesso neq 'DESENVOLVEDORES') and (grpacesso neq 'GESTORMASTER') and (grpacesso neq 'INSPETORES')>
	  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>   
</cfif>            

<cfif isDefined("Form.acao") and #form.acao# is 'VALIDAR'>
	<cfoutput>
		<cfquery datasource="#dsn_inspecao#">
			UPDATE Resultado_Inspecao SET
			 RIP_ReincInspecao = ''
			, RIP_ReincGrupo = 0
			, RIP_ReincItem = 0
			, RIP_UserName = '#CGI.REMOTE_USER#'
			, RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
			WHERE RIP_NumInspecao='#FORM.frminsp#' AND  RIP_Unidade='#FORM.frmunid#' AND RIP_NumGrupo=#FORM.frmgrupo# AND RIP_NumItem=#FORM.frmitem#
		</cfquery>	
	<cflocation url="itens_inspetores_avaliacao1.cfm?Unid=#FORM.frmunid#&Ninsp=#FORM.frminsp#&Ngrup=#FORM.frmgrupo#&Nitem=#FORM.frmitem#&tpunid=#form.tpunid#&frminspreincidente=#FORM.frminspreincidente#&retornosn=#form.retornosn#&frmsituantes=#form.frmsituantes#&frmdescantes=#form.frmdescantes#">  
	</cfoutput> 
</cfif>

<cfif isDefined("Form.acao") and #form.acao# is 'NAOVALIDAR'>
<cfoutput>
	 <cfquery datasource="#dsn_inspecao#">
		UPDATE Resultado_Inspecao SET
		 RIP_ReincInspecao = ''
		, RIP_ReincGrupo = 0
		, RIP_ReincItem = 0
		, RIP_UserName = '#CGI.REMOTE_USER#'
		, RIP_DtUltAtu = CONVERT(char, GETDATE(), 120)
        WHERE RIP_NumInspecao='#FORM.frminsp#' AND  RIP_Unidade='#FORM.frmunid#' AND RIP_NumGrupo=#FORM.frmgrupo# AND RIP_NumItem=#FORM.frmitem#
	  </cfquery> 
	  <cflocation url="itens_inspetores_avaliacao1.cfm?Unid=#FORM.frmunid#&Ninsp=#FORM.frminsp#&Ngrup=#FORM.frmgrupo#&Nitem=#FORM.frmitem#&tpunid=#form.tpunid#&frmsituantes=#frmsituantes#&frmdescantes=#form.frmdescantes#"> 
</cfoutput>
</cfif>

<cfquery name="qResposta" datasource="#dsn_inspecao#">
 SELECT RIP_NumInspecao, UND_DESCRICAO, Pos_Area, 
 Pos_NomeArea, 
 Pos_Inspecao,
 Pos_Situacao_Resp, 
 Pos_Parecer, 
 RIP_Recomendacoes, 
 RIP_Comentario, 
 RIP_Caractvlr, 
 RIP_Falta, 
 RIP_Sobra, 
 RIP_EmRisco, 
 RIP_Valor, 
 RIP_ReincInspecao, 
 RIP_ReincGrupo, 
 RIP_ReincItem, 
 Pos_Processo, 
 Pos_Tipo_Processo, 
 Pos_Abertura, 
 Itn_Descricao, 
 Itn_TipoUnidade, 
 Itn_Classificacao,
 Pos_VLRecuperado, 
 Pos_DtPrev_Solucao, 
 Pos_DtPosic, 
 DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS diasOcor, 
 Pos_SEI, 
 Pos_Situacao_Resp, 
 INP_DtInicInspecao, 
 INP_TNCClassificacao, 
 Pos_NCISEI,
 Pos_ClassificacaoPonto, 
 Pos_PontuacaoPonto,
 Grp_Descricao,
 Pos_NumProcJudicial,
 STO_Descricao
FROM ((((Resultado_Inspecao 
INNER JOIN Unidades ON RIP_Unidade = Und_Codigo) 
INNER JOIN Inspecao ON (RIP_NumInspecao = INP_NumInspecao) AND (RIP_Unidade = INP_Unidade)) 
INNER JOIN Itens_Verificacao ON (convert(char(4),Rip_Ano) = Itn_Ano) and (INP_Modalidade = Itn_Modalidade) AND (Und_TipoUnidade = Itn_TipoUnidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo))
INNER JOIN Grupos_Verificacao ON (Itn_Ano = Grp_Ano) AND (Itn_NumGrupo = Grp_Codigo)) 
left JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)
left JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
WHERE RIP_Unidade ='#nunid#' AND RIP_NumGrupo = #ngrup# AND RIP_NumItem = #nitem# and Pos_Situacao_Resp in(1,6,7,17,22,2,4,5,8,20,15,16,18,19,23)
order by RIP_NumInspecao desc
</cfquery>

<cfquery dbtype="query" name="rsOrdem">
SELECT * FROM qResposta order by Pos_Inspecao
</cfquery>

<cfset anoinsp = right(ninsp,4)> 
	        
<cfquery name="qUsuario" datasource="#dsn_inspecao#">
  SELECT DISTINCT Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_DR, Usu_Email, Usu_Coordena
  FROM Usuarios
  WHERE Usu_Login = '#CGI.REMOTE_USER#'
  GROUP BY Usu_DR, Usu_Apelido, Usu_Lotacao, Usu_LotacaoNome, Usu_Email, Usu_Coordena
</cfquery>

<cfquery name="rsSEINCI" datasource="#dsn_inspecao#">
 SELECT Pos_NCISEI FROM ParecerUnidade WHERE Pos_Unidade='#nunid#' AND Pos_Inspecao='#ninsp#' AND Pos_NCISEI Is Not Null ORDER BY Pos_NCISEI DESC
</cfquery>

<!--- <cfdump var="#url#"> <cfabort> --->

<!--- Nova consulta para verificar respostas das unidades --->
<cfquery name="qSituacaoResp" datasource="#dsn_inspecao#">
  SELECT Pos_Situacao_Resp, Pos_NomeArea, Pos_Area
  FROM ParecerUnidade
  WHERE Pos_Unidade='#nunid#' AND Pos_Inspecao='#ninsp#' AND Pos_NumGrupo=#ngrup# AND Pos_NumItem=#nitem#
</cfquery>

<cfquery name="qResponsavel" datasource="#dsn_inspecao#">
    SELECT INP_Responsavel
    FROM Inspecao
    WHERE (INP_NumInspecao = '#ninsp#')
</cfquery>
<!--- Visualizacao de anexos --->
<cfquery name="qAnexos" datasource="#dsn_inspecao#">
  SELECT Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
  FROM Anexos
  WHERE  Ane_NumInspecao = '#ninsp#' AND Ane_Unidade = '#nunid#' AND Ane_NumGrupo = #ngrup# AND Ane_NumItem = #nitem# 
  order by Ane_Codigo
</cfquery>

<cfquery name="qCausa" datasource="#dsn_inspecao#">
  SELECT Cpr_Codigo, Cpr_Descricao FROM CausaProvavel WHERE Cpr_Codigo not in (select PCP_CodCausaProvavel from ParecerCausaProvavel
  WHERE PCP_Unidade='#nunid#' AND PCP_Inspecao='#ninsp#' AND PCP_NumGrupo=#ngrup# AND PCP_NumItem=#nitem#)
  ORDER BY Cpr_Descricao
</cfquery>
<cfquery name="qSeiApur" datasource="#dsn_inspecao#">
	SELECT SEI_NumSEI FROM Inspecao_SEI 
	WHERE SEI_Unidade='#nunid#' AND SEI_Inspecao='#ninsp#' AND SEI_Grupo=#ngrup# AND SEI_Item=#nitem#
	ORDER BY SEI_NumSEI
</cfquery>
<cfquery name="qProcSei" datasource="#dsn_inspecao#">
	SELECT PDC_ProcSEI, PDC_Processo, PDC_Modalidade FROM Inspecao_ProcDisciplinar
	WHERE PDC_Unidade='#nunid#' AND PDC_Inspecao='#ninsp#' AND PDC_Grupo=#ngrup# AND PDC_Item=#nitem#
	ORDER BY PDC_ProcSEI
</cfquery>

<cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

<cfif isDefined("Form.Ninsp") and form.Ninsp neq "">

	<cfparam name="URL.Unid" default="#Form.Unid#">
	<cfparam name="URL.Ninsp" default="#Form.Ninsp#">
	<cfparam name="URL.Ngrup" default="#Form.Ngrup#">
	<cfparam name="URL.Nitem" default="#Form.Nitem#">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="#form.dtfinal#">
	<cfparam name="URL.DtInic" default="#form.dtinicio#">
	<cfparam name="URL.dtFim" default="#form.dtfinal#">
	<cfparam name="URL.Reop" default="#Form.Reop#">
	<cfparam name="URL.ckTipo" default="#form.ckTipo#">
	<cfparam name="URL.SE" default="#Form.SE#">
	<cfparam name="URL.selstatus" default="#form.selstatus#">
	<cfparam name="URL.statusse" default="#Form.statusse#">
	<cfparam name="URL.sfrmPosArea" default="#Form.sfrmPosArea#">
	<cfparam name="URL.sfrmPosNomeArea" default="#form.sfrmPosNomeArea#">
	<cfparam name="URL.sfrmTipoUnidade" default="#Form.sfrmTipoUnidade#">
	<cfparam name="URL.VLRDEC" default="#Form.sVLRDEC#">
	<cfparam name="URL.situacao" default="#Form.situacao#">
	<cfparam name="URL.posarea" default="#Form.posarea#">
	<cfset auxavisosn = "N">
<cfelse>

	<cfparam name="URL.Unid" default="0">
	<cfparam name="URL.Ninsp" default="">
	<cfparam name="URL.Ngrup" default="">
	<cfparam name="URL.Nitem" default="">
	<cfparam name="URL.Desc" default="">
	<cfparam name="URL.DGrup" default="0">
	<cfparam name="URL.numpag" default="0">
	<cfparam name="URL.dtFinal" default="0">
	<cfparam name="URL.DtInic" default="0">
	<cfparam name="URL.dtFim" default="0">
	<cfparam name="URL.Reop" default="">
	<cfparam name="URL.ckTipo" default="">
	<cfparam name="URL.SE" default="">
	<cfparam name="URL.selstatus" default="">
	<cfparam name="URL.statusse" default="">
	<cfparam name="URL.sfrmPosArea" default="">
    <cfparam name="URL.sfrmPosNomeArea" default="">
    <cfparam name="URL.sfrmTipoUnidade" default="">
	<cfparam name="URL.VLRDEC" default="">
	<cfparam name="URL.situacao" default="">		
	<cfparam name="URL.posarea" default="">
	<cfset auxavisosn = "S">
</cfif> 
<cfquery name="rsTercTransfer" datasource="#dsn_inspecao#">
  SELECT Und_CodDiretoria, Und_Codigo, Und_Descricao, Und_Email
  FROM Unidades 
  WHERE Und_Status = 'A' and Und_CodDiretoria = '#left(URL.posarea,2)#' and Und_TipoUnidade in (12,16)
</cfquery>
<cfquery name="rsUnidTransfer" datasource="#dsn_inspecao#">
  SELECT Und_CodDiretoria, Und_Codigo, Und_Descricao, Und_Email
  FROM Unidades 
  WHERE Und_Status = 'A' and Und_CodDiretoria = '#left(URL.posarea,2)#' and Und_TipoUnidade not in (12,16)
</cfquery>
<cfquery name="rsReopTransfer" datasource="#dsn_inspecao#">
  SELECT Rep_Codigo, Rep_Nome, Rep_Email 
  FROM Reops 
  WHERE Rep_Status = 'A' and Rep_CodDiretoria = '#left(URL.posarea,2)#'
</cfquery>

<cfset auxtransfer = 'N'>
<cfif left(URL.Unid,2) neq left(url.posarea,2)>
 <cfset auxtransfer = 'S'>
</cfif>

 <cfquery name="rsMod" datasource="#dsn_inspecao#">
  SELECT Und_Centraliza, Und_Descricao, Und_CodReop, Und_Codigo, Und_CodDiretoria, Und_Centraliza, Und_TipoUnidade, Und_Email, Dir_Descricao, Dir_Codigo, Dir_Sigla, Dir_Sto, Dir_Email
  FROM Unidades INNER JOIN Diretoria ON Und_CodDiretoria = Dir_Codigo
  WHERE Und_Codigo = '#nunid#'
</cfquery> 


<cfquery name="qCausaProcesso" datasource="#dsn_inspecao#">
 SELECT Cpr_Codigo, Cpr_Descricao, PCP_Unidade, PCP_CodCausaProvavel  FROM ParecerCausaProvavel INNER JOIN CausaProvavel ON PCP_CodCausaProvavel =
 Cpr_Codigo WHERE PCP_Unidade='#URL.unid#' AND PCP_Inspecao='#URL.ninsp#' AND PCP_NumGrupo=#URL.ngrup# AND PCP_NumItem=#URL.nitem#
</cfquery>

<cfset vRecom = 0>

<html>
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript" src="ckeditor\ckeditor.js"></script>

<script type="text/javascript">
<cfinclude template="mm_menu.js">

//reinicia o ckeditor para inibir o erro de retornar conteúdo vazio no textarea
function CKupdate(){
    for ( instance in CKEDITOR.instances )
    CKEDITOR.instances[instance].updateElement();
}
function validarform(){

	var frm = document.forms[0];
	var totreg = frm.frmtotreincidente.value;	
	var auxretornosn = frm.retornosn.value;
	   
	if (totreg == 2 && auxretornosn == 'N') {
	//alert(totreg);
		  if((frm.rdb1[1].checked  == false || frm.rdb2[1].checked  == false) && frm.acao.value == 'VALIDAR'){
		  alert('Responder todas as perguntas acerca das amostras consideradas na avaliação dos itens!');
		  return false;
	   } 
	   } 
	if (totreg >= 3 && auxretornosn == 'N') {
		  if((frm.rdb1[1].checked  == false || frm.rdb2[1].checked  == false || frm.rdb3[1].checked  == false) && frm.acao.value == 'VALIDAR'){
		  alert('Responder todas as perguntas acerca das amostras consideradas na avaliação dos itens!');
		  return false;
	   } 
	 }  
//return false;
}
//=============================
//              a               b            c          d                     e
//fazgestao('#auxcont#','#RIP_NumInspecao#','S','#Pos_Situacao_Resp#','#STO_Descricao#')">
function fazgestao(a,b,c,d,e){
	//alert(a + b + c + d);
	var frm = document.forms[0];
	var auxnumreg = frm.frmtotreincidente.value;

	if (a == 1) {
	   frm.ponto1.value = a + '' + b + '' + c + '' + d;
	   } 
	if (a == 2) {
	   frm.ponto2.value = a + '' + b + '' + c + '' + d;
	   } 
	if (a == 3) {
	   frm.ponto3.value = a + '' + b + '' + c + '' + d;
	   }  

//------------------------------------------------------
if (auxnumreg == 3){
	   	frm.rdb1[0].disabled  = false;
		frm.rdb1[1].disabled  = false;
        //------------
	   	frm.rdb2[0].disabled  = false;
		frm.rdb2[1].disabled  = false;
        //------------
	   	frm.rdb3[0].disabled  = false;
		frm.rdb3[1].disabled  = false;	
}	
if (auxnumreg == 2){
	
	   	frm.rdb1[0].disabled  = false;
		frm.rdb1[1].disabled  = false;
		
        //------------
	   	frm.rdb2[0].disabled  = false;
		frm.rdb2[1].disabled  = false;
        //------------
	 // frm.rdb3[0].disabled  = false;
	//	frm.rdb3[1].disabled  = false;	
}			
//-----------------------------------------------------
	if (a == 1 && c == 'S') 
	{
	   if (auxnumreg == 2) {
	    frm.rdb2[0].checked   = false;
		frm.rdb2[1].checked   = false;
	   	frm.rdb2[0].disabled  = true;
		frm.rdb2[1].disabled  = true;
	   }
	   if (auxnumreg == 3) {
	    frm.rdb3[0].checked   = false;
		frm.rdb3[1].checked   = false;
	   	frm.rdb3[0].disabled  = true;
		frm.rdb3[1].disabled  = true;
	   }	   
	 } 
//-----------------------------------------------------
	if (a == 1 && c == 'N') 
	{
	   if (auxnumreg == 2) {
	    frm.rdb2[0].checked   = false;
	   	frm.rdb2[0].disabled  = false;
		frm.rdb2[1].disabled  = false;
	   }
	   if (auxnumreg == 3) {
	    frm.rdb3[0].checked   = false;
	   	frm.rdb3[0].disabled  = false;
		frm.rdb3[1].disabled  = false;
	   }	   
	 } 	 
//-----------------------------------------
	if (a == 2 && c == 'S') 
	{
	    frm.rdb1[0].checked   = false;
		frm.rdb1[1].checked   = false;
	   	frm.rdb1[0].disabled  = true;
		frm.rdb1[1].disabled  = true;

	   if (auxnumreg == 3) {
	    frm.rdb3[0].checked   = false;
		frm.rdb3[1].checked   = false;
	   	frm.rdb3[0].disabled  = true;
		frm.rdb3[1].disabled  = true;
	   }	   
	 } 
//-----------------------------------------
	if (a == 2 && c == 'N') 
	{
	    frm.rdb1[0].checked   = false;
	   	frm.rdb1[0].disabled  = false;
		frm.rdb1[1].disabled  = false;

	   if (auxnumreg == 3) {
	    frm.rdb3[0].checked   = false;
	   	frm.rdb3[0].disabled  = false;
		frm.rdb3[1].disabled  = false;
	   }	   
	 }   	   
//---------------------------------------------	 
	if (a == 3 && c == 'S') 
	{
	    frm.rdb1[0].checked   = false;
		frm.rdb1[1].checked   = false;
	   	frm.rdb1[0].disabled  = true;
		frm.rdb1[1].disabled  = true;
        //------------
	    frm.rdb2[0].checked   = false;
		frm.rdb2[1].checked   = false;
	   	frm.rdb2[0].disabled  = true;
		frm.rdb2[1].disabled  = true;
	 }  
//---------------------------------------------	 
	if (a == 3 && c == 'N') 
	{
	    frm.rdb1[0].checked   = false;
	   	frm.rdb1[0].disabled  = false;
		frm.rdb1[1].disabled  = false;
        //------------
	    frm.rdb2[0].checked   = false;
	   	frm.rdb2[0].disabled  = false;
		frm.rdb2[1].disabled  = false;
	 }  	 
//------------------------------------
	if (c == 'S'){
		frm.frminspreincidente.value = b;  
		frm.frmsituantes.value = d;
		frm.frmdescantes.value = e;
		frm.retornosn.value = c;
	}
//------------------------------------	
//	if (c == 'N' && (frm.frminspreincidente.value=='' || frm.frminspreincidente.value < b)){
if (c == 'N' && frm.frminspreincidente.value <= b){	
		frm.frminspreincidente.value = b;  
		frm.frmsituantes.value = d;
		frm.frmdescantes.value = e;
		frm.retornosn.value = c;	
	}
//------------------------------------	
	if (auxnumreg == 1){
		frm.frminspreincidente.value = b;  
		frm.frmsituantes.value = d;
		frm.frmdescantes.value = e;
		frm.retornosn.value = c;
	}	
	
//frm.retornosn.value = c;
//var auxamostrasn = c;
	frm.validar.disabled=false;
	 //=================================================================
//	 alert('valor atribuido1: frm.frminspreincidente.value:' + frm.frminspreincidente.value + ' frm.frmsituantes.value:' + frm.frmsituantes.value + ' frm.frmdescantes.value:' + frm.frmdescantes.value + ' frm.retornosn.value:' + frm.retornosn.value);
//	 alert('valor atribuido2: ' + frm.ponto2.value);
//	 alert('valor atribuido3: ' + frm.ponto3.value);
      
}	

</script>
</head>

<body onLoad="aviso();document.form1.validar.disabled=true"> 
<cfset form.acao = ''>
 <cfinclude template="cabecalho.cfm">
<table width="91%"  align="center" bordercolor="f7f7f7">
  
  <tr>
    <td height="20" colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td height="10" colspan="2"><table width="1279">

      <tr>
        <td><div align="center"><strong class="titulo1">NÃO CONFORMIDADE(S) REGISTRADA(S) PARA A UNIDADE EM RELATÓRIO(S) ANTERIORE(S) - ITEM <cfoutput>#URL.Ngrup#.#URL.Nitem#</cfoutput></strong></div>		</td>
        </tr>
      <tr>
        <td>&nbsp;</td>
      </tr>		
    </table></td>
  </tr>
  <cfset Num_Insp_atual = Left(ninsp,2) & '.' & Mid(ninsp,3,4) & '/' & Right(ninsp,4)>
  <form name="form1" method="post" onSubmit="return validarform()" enctype="multipart/form-data" action="itens_inspetores_reincidencia.cfm">
  <cfset exibirnuminspecao = ''>
  <cfset auxcont = 0>
   <cfoutput>
 <cfloop query="rsOrdem">
   <cfset auxfrminspatual = #rsOrdem.RIP_NumInspecao#>
  <cfif len(exibirnuminspecao) lte 0>
  	<cfset exibirnuminspecao = Left(rsOrdem.RIP_NumInspecao,2) & '.' & Mid(rsOrdem.RIP_NumInspecao,3,4) & '/' & Right(rsOrdem.RIP_NumInspecao,4)>
  <cfelse>
	<cfset exibirnuminspecao = exibirnuminspecao & ' e ' & Left(rsOrdem.RIP_NumInspecao,2) & '.' & Mid(rsOrdem.RIP_NumInspecao,3,4) & '/' & Right(rsOrdem.RIP_NumInspecao,4)>  
  </cfif>
 </cfloop>
<!--- exibirnuminspecao: #exibirnuminspecao# --->
</cfoutput>
<cfoutput query="qResposta">
    <cfset auxcont = auxcont + 1>
	<cfif qResposta.RIP_NumInspecao eq ninsp>
	   <cfset db_reincInsp = #ninsp#>
	   <cfset db_reincGrup = #ngrup#>
	   <cfset db_reincItem = #nitem#>
	<cfelse> 
	   <cfset db_reincInsp = #trim(qResposta.RIP_ReincInspecao)#>
	   <cfset db_reincGrup = #qResposta.RIP_ReincGrupo#>
	   <cfset db_reincItem = #qResposta.RIP_ReincItem#>
	   <cfif qResposta.RIP_NumInspecao neq ninsp>		   
		   <cfset auxdb_reincInsp = #trim(qResposta.RIP_NumInspecao)#>
		   <cfset auxdb_reincGrup = #ngrup#>
		   <cfset auxdb_reincItem = #nitem#>
	  <cfelse>
		   <cfset db_reincInsp = #auxdb_reincInsp#>
		   <cfset db_reincGrup = #auxdb_reincGrup#>
		   <cfset db_reincItem = #auxdb_reincItem#>		  
	  </cfif>			   
	</cfif> 
	<cfset Num_Insp = Left(RIP_NumInspecao,2) & '.' & Mid(RIP_NumInspecao,3,4) & '/' & Right(RIP_NumInspecao,4)>
	<cfset Num_Unid = Left(URL.nunid,2) & '.' & Mid(URL.nunid,3,5) & '-' & Right(URL.nunid,1)>
<tr bgcolor="eeeeee">
      <td width="101" class="exibir">N&ordm; Relat&oacute;rio:</td>
      <td width="1173"><table width="1173" border="0">
        <tr>
          <td width="115"><strong class="exibir">#Num_Insp#</strong></td>
          <td width="74" class="exibir">Grupo/Item:</td>
          <td class="exibir"><strong>#URL.Ngrup#.#URL.Nitem# - </strong>#Itn_Descricao#            <div class="icones" width="10%" colspan="2" align="center">
              <div align="right"></div>
            </div></td>
          </tr>
      </table>
        <div align="right"></div></td>
      </tr>

	  <tr bgcolor="eeeeee" class="exibir">
      <td width="101">Situação Atual: </td>

      <td>
		  <table width="100%" border="0" cellspacing="0" >
		  <tr bgcolor="eeeeee" class="form">
			  <td width="29%" bgcolor="eeeeee">&nbsp;<span class="exibir"><strong>#STO_Descricao#</strong></span></td>
					<td width="21%" bgcolor="eeeeee">Data  Posição: <span class="exibir"><strong>#dateformat(Pos_DtPosic,"DD/MM/YYYY")#</strong></span></td>
					<td width="50%" bgcolor="eeeeee">Data  Previsão Solução:&nbsp;<span class="exibir"><strong>#dateformat(Pos_DtPrev_Solucao,"DD/MM/YYYY")#</strong></span> </td>
		  </tr>
		  </table>	  </td>
      </tr>
<!---  <td width="274"></tr> --->

 	  	 <cfset melhoria = replace('#qResposta.RIP_Comentario#','; ' ,';','all')>
		<tr>
         <td width="101" align="center" bgcolor="eeeeee" class="exibir">Situação Encontrada:</td>
        <td colspan="2" bgcolor="f7f7f7"><textarea name="Melhoria" cols="200" rows="20" wrap="VIRTUAL" class="form" readonly>#melhoria#</textarea></td>
      </tr>	
	<!---  --->  

    <tr bgcolor="eeeeee">
      <td height="30" colspan="3" align="center" valign="middle"><hr></td>
    </tr>
    <tr>
      <td height="32" colspan="3" align="center" valign="middle" bgcolor="##EEEEEE"><table width="920" class="exibir">
        <tr class="titulos">
          <td colspan="3" class="exibir"><div align="center">O período/amostra considerados para realização das avaliações são idênticos? (Item #URL.Ngrup#.#URL.Nitem# - Relatório #Num_Insp# e Item #URL.Ngrup#.#URL.Nitem# - Relatório #Num_Insp_atual#)</div></td>
          </tr>
        <tr>
          <td colspan="3" class="exibir"><div align="center"><strong>Atenção:</strong> Antes da confirmação de uma das opções "Sim" ou "Não", ler atentamente as orientações disponibilizadas <a href="abrir_pdf_act.cfm?arquivo=\\sac0424\SISTEMAS\SNCI\GUIAS\Orientar_Reg_Reincidencia.pdf"><span class="exibir"><strong>Aqui.</strong></span></a></div></td>
          </tr>
        <tr>
          <td colspan="3" class="exibir"><hr></td>
          </tr>
        <tr>
		<td width="324" class="exibir">&nbsp;</td>
          <td width="195" valign="middle"><label>
		    <cfset rdb = 'rdb' & #auxcont#>
            <input name="#rdb#" type="radio" value="S" onClick="fazgestao('#auxcont#','#RIP_NumInspecao#','S','#Pos_Situacao_Resp#','#STO_Descricao#')">
              <strong>Sim</strong>              </label></td>
          
          <td width="385" valign="middle"><label>
            <input name="#rdb#" type="radio" value="N" onClick="fazgestao('#auxcont#','#RIP_NumInspecao#','N','#Pos_Situacao_Resp#','#STO_Descricao#')">
              <strong>Não</strong>              </label></td>
        </tr>

        <tr>
          <td colspan="3" class="exibir"><hr></td>
          </tr>
      </table></td>
    </tr>
	    <tr bgcolor="eeeeee">
      <td height="16" colspan="3" align="center" valign="middle" bgcolor="##FFFFFF">&nbsp;</td>
    </tr>
 </cfoutput>
     <tr bgcolor="eeeeee">
  <td height="32" colspan="3" align="center" valign="middle">
    <table width="935" border="0">
    <tr>
      <td width="376">
    	          <div align="center">
    	            <input name="naovalidar" type="Submit" class="titulos" value="Voltar" onClick="document.form1.acao.value='NAOVALIDAR';">
    	          </div></td>
      <td width="99">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <label></label>        
        &nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td width="446"><div align="center">
	      <input name="validar" type="Submit" class="titulos" value="Confirmar" onClick="document.form1.acao.value='VALIDAR';ajustardados()">
	        </div>        </td>
      </tr>
  </table></td>
  <tr>
  
<cfif isdefined('retornosn') and (retornosn eq 'S' or retornosn eq 'N')>
		<cfif listfind('2,4,5,8,15,16,19,23,1,6,7,22,9,10,31,24,32','#frmsituantes#')>
			<cfif retornosn eq 'S'>		
			<cfset restringirSN = 'S'>
			<cfset auxjustificativa = 'Os fatos identificados como Não Conforme foram registrados no relatório anterior : Avaliação: ' & #frminspreincidente# & ' Grupo/Item: ' & #ngrup# & '-' & #nitem# & ' com situação atual em: ' & #frmdescantes#>  
			<cfset Form.Melhoria = #auxjustificativa#>  
			<cfset Form.recomendacao = ''>
			<cfset auxvlr = 'C'>
			<cfset auxdescvlr = 'CONFORME'>
			
		</cfif>	
		<cfif retornosn eq 'N'>

			<cfset auxjustificativa = ''> 
			<cfset restringirSN = 'S'>
			<cfset auxvlr = 'N'>
			<cfset auxdescvlr = 'NÃO CONFORME'>		
			<cfset Form.Melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)# & '<p><strong>Possíveis Consequências da Situação Encontrada:</strong>'>	
			<cfset Form.recomendacao = #rsItem.Itn_OrientacaoRelato#>	 
		</cfif>	
		<cfelseif listfind('3,29','#frmsituantes#')>
				<cfset restringirSN = 'S'>
				<cfset auxvlr = 'N'>
				<cfset auxdescvlr = 'NÃO CONFORME'>
				<cfset Form.Melhoria = #rsItem.Itn_PreRelato# & '<strong>Ref. Normativa:</strong>' & #Trim(rsItem.Itn_Norma)# & '<p><strong>Possíveis Consequências da Situação Encontrada:</strong>'>
				<cfset Form.recomendacao = #rsItem.Itn_OrientacaoRelato#>	
			<cfif retornosn eq 'N'>
				<cfset restringirSN = 'N'>
			</cfif>				
		</cfif>	 	
</cfif>	  
<input type="hidden" name="frminsp" value="<cfoutput>#ninsp#</cfoutput>">
<input type="hidden" name="frminspantes" value="<cfoutput>#qResposta.Pos_Inspecao#</cfoutput>">
<input type="hidden" name="frmunid" value="<cfoutput>#nunid#</cfoutput>">
<input type="hidden" name="frmgrupo" value="<cfoutput>#ngrup#</cfoutput>">
<input type="hidden" name="frmitem" value="<cfoutput>#nitem#</cfoutput>">
<input type="hidden" name="frminspatual" value="<cfoutput>#auxfrminspatual#</cfoutput>">
<input type="hidden" name="TPUNID" value="<cfoutput>#qResposta.Itn_TipoUnidade#</cfoutput>">
<input type="hidden" name="frminspreincidente" value=""> 
<input type="hidden" name="frmexibirnuminspecao" value="<cfoutput>#exibirnuminspecao#</cfoutput>">
<input type="hidden" name="frmtotreincidente" value="<cfoutput>#qResposta.recordcount#</cfoutput>">
<!--- <input type="hidden" name="frmavaliacaoantes" value=""> --->
<input type="hidden" name="frmsituantes" value="">
<input type="hidden" name="frmdescantes" value="">
<!--- <input type="hidden" name="frmamostraigualsn" value=""> --->

<input type="hidden" id="acao" name="acao" value="">
<input type="hidden" id="amostra" name="amostra" value="">
<input type="hidden" id="qtdamostrasanalisadas" name="qtdamostrasanalisadas" value="">
<input type="hidden" id="amostraeleita" name="amostraeleita" value=""> 
<input type="hidden" id="ponto1" name="ponto1" value=""> 
<input type="hidden" id="ponto2" name="ponto2" value=""> 
<input type="hidden" id="ponto3" name="ponto3" value=""> 
<input type="hidden" id="retornosn" name="retornosn" value=""> 
 </form>
  <!--- Fim area de conteudo --->
</table>

</body>

<script>
CKEDITOR.replace('Melhoria', {
		width: '1020',
		height: 200,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',
<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find' ],
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','-','Imagem', '-','Maximize','Table'  ]
		]
    });
	CKEDITOR.replace('recomendacao', {
		width: '1020',
		height: 100,
		removePlugins: 'scayt',
        disableNativeSpellChecker: false,
		line_height:'1px',
<!--- 		enterMode:CKEDITOR.ENTER_DIV, ao invés de <p> coloca <div> após enter--->
<!--- 		enterMode:2,forceEnterMode:false,shiftEnterMode:1,  transforma enter em <br> shift+enter <p>--->
		toolbar: [
			[ 'Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat','-', 'Undo', 'Redo', '-','Find' ],
			['SelectAll', '-'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-','TextColor', 'BGColor','Maximize','Table'  ]
		]
			
    });


function aviso(){
var frminsp = document.form1.frminspantes.value;
var frmgrupo = document.form1.frmgrupo.value;
var frmitem = document.form1.frmitem.value;
var texto = 'Senhor(a) Inspetor(a)\n\nO Grupo/item em avaliação foi registrado como "Não Conforme" no(s) Relatório(s) ' + document.form1.frmexibirnuminspecao.value + '.\n\nPara cada uma das "Não Conformidades" apresentadas em tela, informar se o período/amostra considerados para a realização da avaliação dos itens são idênticos.';
alert(texto);
}  
</script>

</html>



<cfif isDefined("Session.E01")>
	<cfset StructClear(Session.E01)>
</cfif>


