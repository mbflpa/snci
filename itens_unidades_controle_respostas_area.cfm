<cfprocessingdirective pageEncoding ="utf-8"/>
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False' )>
   <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort>  
 </cfif>      
 <!--- <cfdump var="#url#">
<cfabort>  --->

 <cfif isDefined("Session.E01")>
   <cfset StructClear(Session.E01)>
 </cfif>

 <cfquery name="qAcesso" datasource="#dsn_inspecao#">
   select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR, Usu_LotacaoNome, Dir_Descricao from usuarios 
  INNER JOIN Diretoria ON Diretoria.Dir_Codigo = Usu_DR
  where Usu_login = '#cgi.REMOTE_USER#'
 </cfquery>

 <cfquery name="qArea" datasource="#dsn_inspecao#">
   SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao FROM Areas WHERE Ars_Codigo='#qAcesso.Usu_Lotacao#' AND Ars_Status ='A'
 </cfquery>


<cfif ckTipo eq "1">
  <cfset sigla=qArea.Ars_Sigla>
<cfelse>
  <cfset sigla='TODOS OS ÓRGÃOS SUBORDINADOS À(AO) #qAcesso.Dir_Descricao#'>
</cfif>

<cfif (Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES' ) or (Trim(qAcesso.Usu_GrupoAcesso) eq 'GESTORES' ) or (Trim(qAcesso.Usu_GrupoAcesso) eq 'GERENTES')>

       <cfquery name="rsItem" datasource="#dsn_inspecao#">
        <cfif ckTipo eq "1">
          SELECT Ars_CodGerencia, 
		  INP_DtInicInspecao, 
		  Pos_NumItem, 
		  Pos_Unidade, 
		  Pos_ClassificacaoPonto,
		  DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant, 
		  Unidades.Und_Descricao,               
          Unidades.Und_TipoUnidade, 
		  Pos_Inspecao, 
		  Pos_DtPosic,
		  Pos_DtPrev_Solucao,
		  Pos_NumGrupo, 
		  Pos_dtultatu,
		  Grp_Descricao, 
		  Pos_Situacao_Resp, 
		  RIP_NumInspecao, 
		  RIP_ReincInspecao, 
		  RIP_ReincGrupo, 
		  RIP_ReincItem,
		  Pos_Parecer, 
		  pos_area,
          INP_DtInicInspecao, 
		  INP_DtFimInspecao, 
		  INP_DtEncerramento, 
          STO_Codigo, 
		  STO_Sigla, 
		  STO_Cor, 
		  STO_Descricao, 
		  Itn_Descricao
          FROM ((((Resultado_Inspecao 
          INNER JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_NumItem =
          ParecerUnidade.Pos_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND
          (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_Unidade =
          ParecerUnidade.Pos_Unidade)) 
          INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
          INNER JOIN (Itens_Verificacao 
          INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo AND Itn_Ano = Grp_Ano) 
		  ON convert(char(4),RIP_Ano) = Itn_Ano and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (Itn_TipoUnidade = Und_TipoUnidade)) 
          INNER JOIN Areas ON Pos_Area =  Ars_Codigo) 
          INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade) AND (INP_Modalidade = Itn_Modalidade)
          INNER JOIN Situacao_Ponto ON
          Pos_Situacao_Resp = STO_Codigo
          WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#') and (Pos_Situacao_Resp in (5,19)) AND Ars_Status='A' 
        <cfelse>
          SELECT Ars_CodGerencia,                      
                 INP_DtInicInspecao,                   
                 Pos_NumItem,                         
                 Pos_Unidade,       
				 Pos_ClassificacaoPonto,                  
                 DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant,
                 Unidades.Und_Descricao,               
                 Unidades.Und_TipoUnidade,            
                 Pos_Inspecao,                        
                 Pos_NumGrupo,                         
                 Pos_dtultatu, 
				 Pos_DtPosic,
				 Pos_DtPrev_Solucao,                       
                 Itn_Descricao,                       
                 Grp_Descricao,                       
                 Pos_Situacao_Resp,                    
                 RIP_NumInspecao,  
				 RIP_ReincInspecao, 
				 RIP_ReincGrupo, 
				 RIP_ReincItem,				                     
                 Pos_Parecer,                         
                 pos_area,                             
                 INP_DtInicInspecao,                   
                 INP_DtFimInspecao,                    
                 INP_DtEncerramento,                  
                 STO_Codigo, 
				 STO_Sigla, 
				 STO_Cor, 
				 STO_Descricao, 
				 Itn_Descricao                   
          FROM ((((Resultado_Inspecao 
          INNER JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_NumItem =
          ParecerUnidade.Pos_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND
          (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_Unidade =
          ParecerUnidade.Pos_Unidade)) 
          INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
          INNER JOIN (Itens_Verificacao 
          INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo AND Itn_Ano = Grp_Ano) 
		  ON convert(char(4),RIP_Ano) = Itn_Ano and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (Itn_TipoUnidade = Und_TipoUnidade)) 
          INNER JOIN Areas ON Pos_Area =  Ars_Codigo) 
          INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade) AND (INP_Modalidade = Itn_Modalidade)
          INNER JOIN Situacao_Ponto ON
          Pos_Situacao_Resp = STO_Codigo

          <cfif '#frmResp#' neq ''> 
            <cfswitch expression='#frmResp#'>
              <cfcase value="N">WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (2,4,5,14,15,16,19) </cfcase>
              <cfcase value="S">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (3) </cfcase>
              <cfcase value="A">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (24) </cfcase>
              <cfcase value="C">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (9) </cfcase>
			  <cfcase value="E">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (29) </cfcase>
            </cfswitch>
		  <cfif frmResp eq 'N' and trim(qAcesso.Usu_LotacaoNome) eq "SUBG SEG CORPOR/GAAV">
		  	or ('#qAcesso.Usu_DR#' = left(Pos_Unidade,2) and Pos_Situacao_Resp in (2,4,5,8,10,14,15,16,18,19,20,22,23)) 
		  </cfif>			
          </cfif>
          <cfset dataInicio='#dtinicial#'>
          <cfset dataFim='#dtfinal#'>

          <cfif dtinicial neq '' and dtfinal neq ''>
            <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
            <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
          </cfif>
          <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
            AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
          </cfif>
        </cfif>
			order by INP_DtEncerramento, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
       </cfquery>

       <cfquery name="rsXLS" datasource="#dsn_inspecao#">
        <cfif ckTipo eq "1">
		 SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp,
         convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade,
         Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, RIP_Ano, RIP_Resposta,
         substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, 
         convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao,
         convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento,
         convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as
         INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao,
         convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel,
         substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao,
         convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area,
         Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo,
         Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant
         FROM ((((Resultado_Inspecao 
          INNER JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_NumItem =
          ParecerUnidade.Pos_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND
          (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_Unidade =
          ParecerUnidade.Pos_Unidade)) 
          INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
          INNER JOIN (Itens_Verificacao 
          INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo AND Itn_Ano = Grp_Ano) 
		  ON convert(char(4),RIP_Ano) = Itn_Ano and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (Itn_TipoUnidade = Und_TipoUnidade)) 
          INNER JOIN Areas ON Pos_Area =  Ars_Codigo) 
          INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade) AND (INP_Modalidade = Itn_Modalidade)
          INNER JOIN Situacao_Ponto ON
          Pos_Situacao_Resp = STO_Codigo
          WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#') and (Pos_Situacao_Resp in (5,19)) AND Ars_Status='A' 
        <cfelse>
		SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp,
         convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade,
         Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, RIP_Ano, RIP_Resposta,
         substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, 
         convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao,
         convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento,
         convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as
         INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao,
         convert(char,INP_DtEncerramento,103) as INPDtEncer, concat (left([INP_Coordenador],1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel,
         substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao,
         convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area,
         Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo,
         Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant
         FROM ((((Resultado_Inspecao 
          INNER JOIN ParecerUnidade ON (Resultado_Inspecao.RIP_NumItem =
          ParecerUnidade.Pos_NumItem) AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) AND
          (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) AND (Resultado_Inspecao.RIP_Unidade =
          ParecerUnidade.Pos_Unidade)) 
          INNER JOIN Unidades ON Pos_Unidade = Und_Codigo) 
          INNER JOIN (Itens_Verificacao 
          INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo AND Itn_Ano = Grp_Ano) 
		  ON convert(char(4),RIP_Ano) = Itn_Ano and (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo) and (Itn_TipoUnidade = Und_TipoUnidade)) 
          INNER JOIN Areas ON Pos_Area =  Ars_Codigo) 
          INNER JOIN Inspecao ON (Pos_Inspecao = INP_NumInspecao) AND (Pos_Unidade = INP_Unidade) AND (INP_Modalidade = Itn_Modalidade)
          INNER JOIN Situacao_Ponto ON
          Pos_Situacao_Resp = STO_Codigo

          <cfif '#frmResp#' neq ''> 
            <cfswitch expression='#frmResp#'>
              <cfcase value="N">WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (2,4,5,14,15,16,19) </cfcase>
              <cfcase value="S">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (3) </cfcase>
              <cfcase value="A">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (24) </cfcase>
              <cfcase value="C">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (9) </cfcase>
			  <cfcase value="E">WHERE (Ars_CodGerencia = '#qAcesso.Usu_Lotacao#' or Ars_CodGerencia in (Select Ars_Codigo From Areas Where Ars_CodGerencia = '#qAcesso.Usu_Lotacao#')) AND pos_situacao_resp in (29) </cfcase>
            </cfswitch>
		  <cfif frmResp eq 'N' and trim(qAcesso.Usu_LotacaoNome) eq "SUBG SEG CORPOR/GAAV">
		  	or ('#qAcesso.Usu_DR#' = left(Pos_Unidade,2) and Pos_Situacao_Resp in (2,4,5,8,10,14,15,16,18,19,20,22,23)) 
		  </cfif>			
          </cfif>
          <cfset dataInicio='#dtinicial#'>
          <cfset dataFim='#dtfinal#'>

          <cfif dtinicial neq '' and dtfinal neq ''>
            <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
            <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
          </cfif>
          <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
            AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
          </cfif>
        </cfif>
			order by INP_DtEncerramento, Pos_Unidade, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem
       </cfquery>

       <html>

       <head>
         <title>Sistema Nacional de Controle Interno</title>
         <link href="CSS.css" rel="stylesheet" type="text/css">
         <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
         <style type="text/css">
           <!--
           .style5 {
             font-size: 14;
             font-weight: bold;
           }
           -->
         </style>
         <link href="css.css" rel="stylesheet" type="text/css">
         <style type="text/css">
           <!--
           .style6 {
             color: #FF0000
           }
           -->
         </style>
         <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
           SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
         </cfquery>
         <cfoutput query="rsSPnt">
           <div id="#rsSPnt.STO_Sigla#"
             style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
             <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font>
           </div>
         </cfoutput>
       </head>

       <body>
 <script language="JavaScript">
 <meta charset UTF-8>

 //inicio calssificar colunas
var index;      // cell index
	// var toggleBool;// sorting asc, desc
	window.onload=function(){
		//recupera a classificação das colunas
		if(sessionStorage.getItem('colClassif')===null){
			toggleBool=true;
			sorting(tbodyItens, 0);
						
		}else{	
			toggleBool=sessionStorage.getItem('colClassifAscDesc');

			sorting(tbodyItens, sessionStorage.getItem('colClassif'),toggleBool);
		}
		//FIM: recupera a classificação das colunas
	};

   //Para classificar tabelas
	
	function sorting(tbody, index){
	//alert(tbody + index);
		sessionStorage.setItem('colClassif', index, toggleBool);
		toggleBool = true;

		var pai = document.getElementById("trItens");
        // for(var i=0; i<pai.children.length; i++){retirado para não classificar a coluna item por solicitação do Adriano
		for(var i=0; i < 5; i++){
			var figuraCresceId = 'classifCrescente' + i;
		    var	figuraDecresceId = 'classifDecrescente' + i;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}

		var frm = document.getElementById('frmopc');
		this.index = index;
		var figuraCresceId = 'classifCrescente' + index;
		var	figuraDecresceId = 'classifDecrescente' + index;
		if(toggleBool){
			toggleBool = false;
			document.getElementById(figuraCresceId).style.display='block';
			document.getElementById(figuraCresceId).style.visibility='visible';
			document.getElementById(figuraDecresceId).style.display='none';
			document.getElementById(figuraDecresceId).style.visibility='hidden';
		}else{
			toggleBool = true;
			document.getElementById(figuraCresceId).style.display='none';
			document.getElementById(figuraCresceId).style.visibility='hidden';
			document.getElementById(figuraDecresceId).style.display='block';
			document.getElementById(figuraDecresceId).style.visibility='visible';
		}

		// sessionStorage.setItem('colClassifAscDesc', toggleBool);retirado para sempre classificar crescente

		var datas= new Array();
		var tbodyLength = tbody.rows.length;
		for(var i=0; i<tbodyLength; i++){
			datas[i] = tbody.rows[i];
		}

		datas.sort(compareCellsGrupo);//obriga a classificação por grupo após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}

		datas.sort(compareCellsItem);//obriga a classificação por grupo e item após escolha da coluna de classificação
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}
		
		datas.sort(compareCells);
		for(var i=0; i<tbody.rows.length; i++){
			tbody.appendChild(datas[i]);
		}   
		
		// for(var i = 0; i < pai.children.length; i++){
		for(var i = 0; i < 5; i++){
			if(document.getElementById('classifCrescente' + i)){
				var figuraCresceId = document.getElementById('classifCrescente' + i).style.visibility;
				var	figuraDecresceId = document.getElementById('classifDecrescente' + i).style.visibility;
			}

			if(pai.children[i].tagName == "TD" && (figuraCresceId=='visible' || figuraDecresceId=='visible')) {
				pai.children[i].style.background='lavender';
			}else{
				pai.children[i].style.background='#eeeeee';
			}

		}
	}

	function compareCells(a,b) {
		var aVal = a.cells[index].innerText;
		var bVal = b.cells[index].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	
	function compareCellsGrupo(a,b) {
	//alert(a + b);
		var aVal = a.cells[5].innerText;
		var bVal = b.cells[5].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}
	function compareCellsItem(a,b) {
		var aVal = a.cells[5].innerText;
		var bVal = b.cells[5].innerText;

		aVal = aVal.replace(/\,/g, '');
		bVal = bVal.replace(/\,/g, '');

		if(toggleBool){
			var temp = aVal;
			aVal = bVal;
			bVal = temp;
		} 

		if(aVal.match(/^[0-9]+$/) && bVal.match(/^[0-9]+$/)){
			return parseFloat(aVal) - parseFloat(bVal);
		}
		else{
			if (aVal < bVal){
				return -1; 
			}else if (aVal > bVal){
					return 1; 
			}else{
				return 0;       
			}         
		}
	}

	//FIM: Para classificar tabelas
		 
           //detectando navegador
           sAgent = navigator.userAgent;
           bIsIE = sAgent.indexOf("MSIE") > -1;
           bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

           //setando as variaveis de controle de eventos do mouse
           var xmouse = 0;
           var ymouse = 0;
           document.onmousemove = MouseMove;

           //funcoes de controle de eventos do mouse:
           function MouseMove(e) {
             if (e) {
               MousePos(e);
             } else {
               MousePos();
             }
           }

           function MousePos(e) {
             if (bIsNav) {
               xmouse = e.pageX;
               ymouse = e.pageY;
             }
             if (bIsIE) {
               xmouse = document.body.scrollLeft + event.x;
               ymouse = document.body.scrollTop + event.y;
             }
           }

           //funcao que mostra e esconde o hint
           function Hint(objNome, action) {
             //action = 1 -> Esconder
             //action = 2 -> Mover

             if (bIsIE) {
               objHint = document.all[objNome];
             }
             if (bIsNav) {
               objHint = document.getElementById(objNome);
               event = objHint;
             }

             switch (action) {
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
         <cfoutput>
           <cfquery name="qUsuario" datasource="#dsn_inspecao#">
             SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
           </cfquery>
         </cfoutput>
         <!--- Excluir arquivos anteriores ao dia atual --->
         <cfset sdata=dateformat(now(),"YYYYMMDDHH")>
           <cfset diretorio=#GetDirectoryFromPath(GetTemplatePath())#>
             <cfset slocal=#diretorio# & 'Fechamento\'>

               <cfoutput>
                 <cfset sarquivo=#DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
               </cfoutput>

               <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
                 <cfoutput query="qList">
                   <cfif len(name) eq 23>
                     <cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
                       <cffile action="delete" file="#slocal##name#">
                     </cfif>
                   </cfif>
                 </cfoutput>
                 <!--- fim exclusão --->

                 <!--- <cftry> --->

                 <cfif Month(Now()) eq 1>
                   <cfset vANO=Year(Now()) - 1>
                     <cfelse>
                       <cfset vANO=Year(Now())>
                 </cfif>

                 <cfset objPOI=CreateObject( "component" , "Excel" ).Init() />

                 <cfset data=now() - 1>
                   <cfset objPOI.WriteSingleExcel( FilePath=ExpandPath( "./Fechamento/" & sarquivo ), Query=rsXLS,
                     ColumnList="INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,posusername,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant"
                     ,
                     ColumnNames="Modalidade,Diretoria,Código Unidade Inspecionada,Unidade Inspecionada,Nº Avaliação,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Código Órgão Condutor,Órgão Condutor,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias"
                     , SheetName="SubordinadorRegional" ) />

                   <!--- <cfcatch type="any">
        <cfdump var="#cfcatch#">
    </cfcatch>
    </cftry> --->
                   <cfinclude template="cabecalho.cfm">
                     <table width="100%" height="45%">
                       <tr>
                         <td valign="top">
                           <!--- Área de conteúdo   --->

                           <!---Cria uma instância do componente Dao--->
                           <cfobject component="CFC/Dao" name="dao">

                             <table width="100%" class="exibir">
							   <tr bgcolor="f7f7f7" class="exibir">
							     <td colspan="11" bgcolor="eeeeee">&nbsp;</td>
							     <td width="8%" bgcolor="eeeeee">&nbsp;</td>
						       </tr>
							   <tr bgcolor="f7f7f7" class="exibir">
							     <td colspan="11" bgcolor="eeeeee"><div align="center"><span class="style5"><cfoutput>#sigla#</cfoutput></span></div></td>
						         <td bgcolor="eeeeee"><div align="center">
					             </div></td>
							   </tr>
							   <tr bgcolor="f7f7f7" class="exibir">
							     <td colspan="12" bgcolor="eeeeee">&nbsp;</td>
						       </tr>
							   <tr bgcolor="f7f7f7" class="exibir">
							     <td colspan="12" bgcolor="eeeeee"><div align="center">
							       <button onClick="window.close()"
                                     class="botao">Fechar</button>
							     </div></td>
						       </tr>
							   <tr bgcolor="eeeeee" class="exibir">
							     <td colspan="12" bgcolor="eeeeee"><div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img
                                         src="icones/excel.jpg" width="50" height="35" border="0"></a></div></td>
						       </tr>
							   <tr bgcolor="eeeeee" class="exibir">
							     <td colspan="12"><cfoutput>Qt. Itens: #rsItem.recordCount#</cfoutput></td>
						       </tr>
							   <tr bgcolor="f7f7f7" class="exibir">							   	  
  						         <td width="6%" bgcolor="eeeeee"><div align="center">Status</div></td>
                                 <!--- <td width="6%" bgcolor="eeeeee"><div align="center">Início</div></td>
                                 <td width="6%" bgcolor="eeeeee"><div align="center">Fim</div></td> --->
								 <td width="6%" bgcolor="eeeeee"><div align="center">Dt. Previsão Solução Até</div></td>
								 <td width="5%" bgcolor="eeeeee"><div align="center">Envio Ponto</div></td> 
                                 <td width="12%" bgcolor="eeeeee"><div align="center">Unidade Inspecionada</div></td> 
                                 <td width="12%" bgcolor="eeeeee"><div align="center">Órgão Condutor</div></td>
                                 <td width="5%" bgcolor="eeeeee"><div align="center">Relatório</div></td> 
                                 <td width="18%" bgcolor="eeeeee"><div align="center">Grupo</div></td>
                                 <td width="8%" bgcolor="eeeeee"><div align="left">Item</div></td>
                                  <td width="12%" bgcolor="eeeeee">&nbsp;</td> 
                                 <!---     <td width="5%" bgcolor="eeeeee"><div align="center">Qtd. Dias</div></td> --->
                                 <td colspan="15%" bgcolor="eeeeee"><div align="right">Classificação</div></td>  
							   </tr>
							  <!---  <tbody id="tbodyItens">	 --->
                               <cfoutput query="rsItem">
							     <cfset numReincInsp = ''>
								 <cfif len(trim(rsItem.RIP_ReincInspecao)) gt 0>
							     	<cfset numReincInsp = 'item REINCIDENTE (' & Left(rsItem.RIP_ReincInspecao,2) & '.' & Mid(rsItem.RIP_ReincInspecao,3,4) & '/' & Right(rsItem.RIP_ReincInspecao,4) & ')'>
								 </cfif>
							      <cfquery name="rsStatus011" datasource="#dsn_inspecao#">
	                                SELECT Pos_Inspecao 
								    FROM ParecerUnidade 
								    WHERE (Pos_Inspecao = '#rsItem.Pos_Inspecao#') AND (Pos_Situacao_Resp = 0 Or Pos_Situacao_Resp = 11)
							      </cfquery>
							     <cfif rsStatus011.recordcount lte 0>
                                 <!---  <cfif rsItem.Pos_Area is '#areaSubordinados#'> --->
                                 <!---Invoca o metodo  DescricaoPosArea para retornar a descricao do órgão condutor--->
                                 <cfinvoke component="#dao#" method="DescricaoPosArea" returnVariable="DescricaoPosArea"
                                   CodigoDaUnidade='#rsItem.pos_area#'>

                                   <tr bgcolor="f7f7f7" class="exibir">										
                                     <td width="6%" bgcolor="#STO_Cor#">
                                       <div align="center"><a <cfif ckTipo eq 2>target="_blank"</cfif>
                                           href="itens_unidades_controle_respostas1_area.cfm?cktipo=#URL.ckTipo#&Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&Nitem=#rsItem.Pos_NumItem#&Situacao=#rsItem.Pos_Situacao_Resp#&areaSubordinados=#rsItem.Ars_CodGerencia#&diasdecor=#data#"
                                           class="exibir" onMouseMove="Hint('#STO_Sigla#',2)"
                                           onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a>                                       </div>                                     </td>
									 <td width="6%">
                                       <div align="center">#DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')#</div>                                     </td>
                                     <td width="5%">
                                       <div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div>                                     </td>
                                     <td width="12%">
                                       <div align="center">#rsItem.Und_Descricao#</div>                                     </td>
                                     <td width="12%">
                                       <div align="center">#DescricaoPosArea#</div>                                     </td>
                                     <td width="5%">
                                       <div align="center">#rsItem.Pos_Inspecao#</div>                                     </td>
                                     <td width="18%">
                                       <div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> -
                                         #rsItem.Grp_Descricao#</div>                                     </td>
                                     <td width="40%" colspan="2">
                                       <div align="justify"><strong>#rsItem.Pos_NumItem#</strong> -
                                         &nbsp;#rsItem.Itn_Descricao#</div>                                     </td>
                                      <td width="12%">
                                       <div align="center" class="red_titulo"><strong>#numReincInsp#</strong></div>                                     </td> 
                                      <cfset auxs = rsItem.Pos_ClassificacaoPonto>
									<td colspan="15%"><div align="center"><div align="center">#auxs#</div></td>   
                                   </tr>
                                   <!---  </cfif> --->
							     </cfif>
                               </cfoutput>
							<!---    </tbody> --->
							
							  <tr bgcolor="f7f7f7" class="exibir">
							    <td colspan="3" bgcolor="eeeeee">&nbsp;</td>
							    <td bgcolor="eeeeee">&nbsp;</td>
							    <td bgcolor="eeeeee">&nbsp;</td>
							    <td bgcolor="eeeeee">&nbsp;</td>
							    <td bgcolor="eeeeee">&nbsp;</td>
							    <td bgcolor="eeeeee">&nbsp;</td>
							    <td width="14%" bgcolor="eeeeee">&nbsp;</td>
							    <!---    <td bgcolor="eeeeee">&nbsp;</td> --->
							   <td colspan="15%" bgcolor="eeeeee">&nbsp;</td> 
						       </tr>
							  <tr bgcolor="f7f7f7" class="exibir">
							     <td colspan="12" bgcolor="eeeeee">
					               <div align="center">
						               <button onClick="window.close()"
                                     class="botao">Fechar</button>
				                 </div></td>
						       </tr>
                           </table>

                             <!--- Fim Área de conteúdo --->
                         </td>
                       </tr>
                     </table>
                     <cfinclude template="rodape.cfm">
       </body>

       </html>

       <cfelse>
         <cfinclude template="permissao_negada.htm">
           <cfabort>
     </cfif>