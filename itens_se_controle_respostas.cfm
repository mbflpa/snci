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
  select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR, Dir_Descricao from usuarios 
  INNER JOIN Diretoria ON Diretoria.Dir_Codigo = Usu_DR
  where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>


<cfif ckTipo eq "1">
 <cfset sigla=qAcesso.Dir_Descricao>
<cfelse>
 <cfset sigla='TODOS OS ÓRGÃO SUBORDINADOS À #qAcesso.Dir_Descricao#'>
</cfif>


<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'SUPERINTENDENTE' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES'>


      <cfquery name="rsItem" datasource="#dsn_inspecao#">
       <cfif ckTipo eq "1">
		SELECT INP_DtInicInspecao, pos_area, Pos_NumItem, Pos_Unidade, DATEDIFF(dd, Pos_DtPosic, GETDATE())
		AS Quant, Und_Descricao, Und_TipoUnidade, Pos_Inspecao, Pos_NumGrupo, Pos_dtultatu, DATEDIFF(dd,Pos_DtPosic,GETDATE()) AS data,
		Itn_Descricao, Grp_Descricao, Pos_ClassificacaoPonto, Pos_Situacao_Resp, Rep_Codigo, Rep_Nome, RIP_NumInspecao, Pos_Parecer,
		INP_DtInicInspecao, INP_DtFimInspecao, INP_DtEncerramento, STO_Codigo, STO_Sigla, STO_Cor, STO_Descricao, Pos_DtPrev_Solucao
		FROM Reops 
		INNER JOIN Resultado_Inspecao 
		INNER JOIN Grupos_Verificacao 
		INNER JOIN Unidades 
		INNER JOIN ParecerUnidade 
		INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
		ON Und_Codigo = Pos_Unidade 
		ON Grp_Codigo = Pos_NumGrupo 
		ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
		ON Rep_Codigo = RIP_CodReop  
		INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem 
		and right([Pos_Inspecao], 4) = Itn_Ano AND Itn_Ano = Grp_Ano and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
		INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
		WHERE  pos_area='#qAcesso.Usu_Lotacao#' AND (pos_situacao_resp IN (8,22,23))

       <cfelse>
         SELECT                       
                INP_DtInicInspecao,                   
                Pos_NumItem,                         
                Pos_Unidade,                         
                DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant,
                Unidades.Und_Descricao,               
                Unidades.Und_TipoUnidade,            
                Pos_Inspecao,                        
                Pos_NumGrupo,                         
                Pos_dtultatu,                        
                Itn_Descricao, 
				Pos_ClassificacaoPonto,                      
                Grp_Descricao,                       
                Pos_Situacao_Resp,                    
                RIP_NumInspecao,                      
                Pos_Parecer,                         
                pos_area,                             
                INP_DtInicInspecao,                   
                INP_DtFimInspecao,                    
                INP_DtEncerramento,
                Pos_DtPrev_Solucao,                  
                STO_Codigo,                          
                STO_Sigla,                           
                STO_Cor,                            
                STO_Descricao                      
           FROM Resultado_Inspecao 
     INNER JOIN ParecerUnidade 
             ON Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem 
                AND Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo 
                AND Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao 
                AND Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade
     INNER JOIN Unidades 
             ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo
     INNER JOIN Itens_Verificacao 
     INNER JOIN Grupos_Verificacao 
             ON Itens_Verificacao.Itn_NumGrupo = Grupos_Verificacao.Grp_Codigo 
             ON ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem 
                AND ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo 
                AND right([Pos_Inspecao], 4) = Itn_Ano AND Itn_Ano = Grp_Ano and Itn_TipoUnidade = Und_TipoUnidade  
     INNER JOIN Inspecao 
             ON ParecerUnidade.Pos_Inspecao = Inspecao.INP_NumInspecao 
                AND ParecerUnidade.Pos_Unidade = Inspecao.INP_Unidade AND INP_Modalidade = Itn_Modalidade
	 INNER JOIN Situacao_Ponto 
             ON ParecerUnidade.Pos_Situacao_Resp = Situacao_Ponto.STO_Codigo

         <cfif '#frmResp#' neq ''> 
           <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#' or Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (2,4,5,8,14,15,16,19,23) </cfcase>
             <cfcase value="S">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (3)</cfcase>
             <cfcase value="A">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (24)</cfcase>
             <cfcase value="R">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12</cfcase>
             <cfcase value="C">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (9) </cfcase>
			 <cfcase value="E">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (29) </cfcase>
           </cfswitch>
         </cfif>
         <cfset dataInicio='#dtinicial#'>
         <cfset dataFim='#dtfinal#'>

         <cfif dtinicial neq '' and dtfinal neq ''>
           <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
           <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
         </cfif>

         <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
           <!--- AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#) --->
		   AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
         </cfif>
       </cfif>

           ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
      </cfquery>

      <cfquery name="rsXLS" datasource="#dsn_inspecao#">
       <cfif ckTipo eq "1">
        SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp,
        convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade,
        Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, RIP_Ano, RIP_Resposta,
        substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco,
        convert(char,RIP_DtUltAtu,120) as RIPDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao,
        convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento,
        convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as
        INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao,
        convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel,
        substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao,
        convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area,
        Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo,
        Grp_Descricao, Itn_Descricao, Pos_ClassificacaoPonto, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant
        FROM Reops 
		INNER JOIN Resultado_Inspecao 
		INNER JOIN Grupos_Verificacao 
		INNER JOIN Unidades 
		INNER JOIN ParecerUnidade 
		INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
		ON Und_Codigo = Pos_Unidade 
		ON Grp_Codigo = Pos_NumGrupo 
		ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
		ON Rep_Codigo = RIP_CodReop  
		INNER JOIN Itens_Verificacao ON Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem 
		and right([Pos_Inspecao], 4) = Itn_Ano AND Itn_Ano = Grp_Ano and Itn_TipoUnidade = Und_TipoUnidade AND (INP_Modalidade = Itn_Modalidade)
		INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
        WHERE  pos_area='#qAcesso.Usu_Lotacao#' AND (pos_situacao_resp IN (8,23) )

       <cfelse>
         SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp,
        convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade,
        Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, RIP_Ano, RIP_Resposta,
        substring(RIP_Comentario,1,32500) as comentario, RIP_Valor, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco,
        convert(char,RIP_DtUltAtu,120) as RIPDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao,
        convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento,
        convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as
        INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao,
        convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel,
        substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao,
        convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area,
        Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo,
        Grp_Descricao, Itn_Descricao, Pos_ClassificacaoPonto, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant
        FROM Resultado_Inspecao 
     INNER JOIN ParecerUnidade 
             ON Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem 
                AND Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo 
                AND Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao 
                AND Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade
     INNER JOIN Unidades 
             ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo
     INNER JOIN Itens_Verificacao 
     INNER JOIN Grupos_Verificacao 
             ON Itens_Verificacao.Itn_NumGrupo = Grupos_Verificacao.Grp_Codigo 
             ON ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem 
                AND ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo 
                AND right([Pos_Inspecao], 4) = Itn_Ano AND Itn_Ano = Grp_Ano and Itn_TipoUnidade = Und_TipoUnidade
     INNER JOIN Inspecao 
             ON Pos_Inspecao = INP_NumInspecao AND Pos_Unidade = INP_Unidade AND (INP_Modalidade = Itn_Modalidade)
				INNER JOIN Situacao_Ponto 
             ON ParecerUnidade.Pos_Situacao_Resp = Situacao_Ponto.STO_Codigo
        <cfif '#frmResp#' neq ''> 
          <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE (Pos_Area = '#qAcesso.Usu_Lotacao#' or Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (2,4,5,8,14,15,16,19,23) </cfcase>
             <cfcase value="S">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (3) </cfcase>
             <cfcase value="A">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (24) </cfcase>
             <cfcase value="R">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12 </cfcase>
             <cfcase value="C">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (9) </cfcase>
			 <cfcase value="E">WHERE (Unidades.Und_CodDiretoria = '#qAcesso.Usu_DR#') AND pos_situacao_resp in (29) </cfcase>
           </cfswitch>
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

        ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
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
                    ColumnList="INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Ano,RIP_Resposta,comentario,RIP_Caractvlr,RIP_Falta,RIP_Sobra,RIP_EmRisco,RIPDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant"
                    ,
                    ColumnNames="Modalidade,Diretoria,Código Unidade Inspecionada,Unidade Inspecionada,Nº Avaliação,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código ANO,Resposta,Comentário,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Avaliação,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Avaliação,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Código Órgão Condutor,Órgão Condutor,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias"
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

                              <tr>
                                <td height="20%" colspan="9">
                                  <div align="center"><span class="style5">
                                      <cfoutput>#sigla#</cfoutput>
                                    </span></div>
                                </td>
                              </tr><br>
                              <tr>
                                <td colspan="9" align="center"> <button onClick="window.close()"
                                    class="botao">Fechar</button></td>
                              </tr>
                              <tr>
                                <td colspan="9">
                                  <div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img
                                        src="icones/excel.jpg" width="50" height="35" border="0"></a></div>
                                </td>
                              </tr>
                              <tr>
                                <td height="20%" colspan="9" class="titulosClaro">
                                  <div align="center">
                                    <cfoutput>
                                      <div align="left">Qt. Itens: #rsItem.recordCount#</div>
                                    </cfoutput>
                                  </div>
                                </td>
                              </tr>
                              <tr class="titulosClaro">							     
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Status</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Início</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Fim</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Envio Ponto </div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Dt. Previsão Solução Até</div>
                                </td>
                                <td width="12%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Unidade Inspecionada</div>
                                </td>
                                <td width="9%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Órgão Condutor</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Relatório</div>
                                </td>
                                <td width="17%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Grupo</div>
                                </td>
                                <td width="20%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Item</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Qdt. Dias</div>
                                </td>
                                <td width="4%" align="center" bgcolor="eeeeee" class="exibir"><div align="center"><strong>Classificação</strong></div></td>
                              </tr>

                              <cfoutput query="rsItem">
                                <!---  <cfif rsItem.Pos_Area is '#areaSubordinados#'> --->
                                <!---Invoca o metodo  DescricaoPosArea para retornar a descricao do órgão condutor--->
                                <cfinvoke component="#dao#" method="DescricaoPosArea" returnVariable="DescricaoPosArea"
                                  CodigoDaUnidade='#rsItem.pos_area#'>

                                  <tr bgcolor="f7f7f7">
                                    <td width="5%" bgcolor="#STO_Cor#">
                                      <div align="center"><a <cfif ckTipo eq 2>target="_blank"</cfif>
                                          href="itens_se_controle_respostas1.cfm?cktipo=#URL.ckTipo#&Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&areaSubordinados=#rsItem.Pos_Area#&diasdecor=#data#"
                                          class="exibir" onMouseMove="Hint('#STO_Sigla#',2)"
                                          onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a>
                                      </div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="3%">
                                      <div align="center">#DateFormat(rsItem.Pos_DtPrev_Solucao,'DD/MM/YYYY')#</div></td>
                                    <td width="12%">
                                      <div align="center">#rsItem.Und_Descricao#</div>
                                    </td>
                                    <td width="12%">
                                      <div align="center">#DescricaoPosArea#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#rsItem.Pos_Inspecao#</div>
                                    </td>
                                    <td width="17%">
                                      <div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> -
                                        #rsItem.Grp_Descricao#</div>
                                    </td>
                                    <td width="20%">
                                      <div align="justify"><strong>#rsItem.Pos_NumItem#</strong> -
                                        &nbsp;#rsItem.Itn_Descricao#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center"><strong>#rsItem.Quant#</strong></div>
                                    </td>
                                    <cfset auxs = rsItem.Pos_ClassificacaoPonto>
									                  <td width="4%"><div align="center"><div align="center">#auxs#</div></td>
                                  </tr>
                                  <!---  </cfif> --->
                              </cfoutput>
                              <tr>
                                <td colspan="9" align="center">&nbsp;</td>
                              </tr>
                              <tr>
                                <td colspan="9" align="center"> <button onClick="window.close()"
                                    class="botao">Fechar</button></td>
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