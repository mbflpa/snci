<cfprocessingdirective pageEncoding ="utf-8"> 
<cfinclude template="../../../parametros.cfm">
<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
	method="geraMatriculaInspetor" returnvariable="qryInspetor">
</cfinvoke>

<cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
	method="geraPapelTrabalho" returnvariable="qryPapelTrabalho">
</cfinvoke>

  <cfquery name="rsRevis" datasource="#dsn_inspecao#">
    select Usu_Apelido 
    from usuarios 
    where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#qryPapelTrabalho.INP_RevisorLogin#">)
  </cfquery>


<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>
<cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>

<cfset qtItens = qryPapelTrabalho.recordcount>
<cfquery name="rsSituacoes" datasource="#dsn_inspecao#">
    SELECT Pos_Situacao_Resp, Pos_NumGrupo, Pos_NumItem, Pos_NCISEI, STO_Descricao, STO_Cor FROM ParecerUnidade
    INNER JOIN Situacao_Ponto ON STO_Codigo = Pos_Situacao_Resp
    WHERE  Pos_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#'
    ORDER BY Pos_Situacao_Resp, Pos_NumGrupo, Pos_NumItem
</cfquery>

<cfquery name="rsRelev" datasource="#dsn_inspecao#">
	SELECT VLR_Fator, VLR_FaixaInicial, VLR_FaixaFinal
	FROM ValorRelevancia
	WHERE VLR_Ano = '#right(qryPapelTrabalho.INP_NumInspecao,4)#'
</cfquery>

<cfquery name = "rsQuatEmRevisao" dbtype = "query" >
    SELECT count(Pos_Situacao_Resp) as quantEmRevisao from rsSituacoes
    WHERE Pos_Situacao_Resp in (0,11)
</cfquery>

<cfquery name="rsItemEmReanalise" datasource="#dsn_inspecao#">
      SELECT RIP_Resposta, RIP_NumGrupo, RIP_NumItem FROM Resultado_Inspecao 
      WHERE RTRIM(RIP_Recomendacao)='S' AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
</cfquery>
  <cfset auxdtprev = CreateDate(year(now()),month(now()),day(now()))>
<!--- <cfif qryPapelTrabalho.TUN_Codigo neq 12 and qryPapelTrabalho.TUN_Codigo neq 16> --->
  <!--- 10 dias úteis na data de previsão --->
  <cfset nCont = 1>
  <cfloop condition="nCont lte 10">
    <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
    <cfset vDiaSem = DayOfWeek(auxdtprev)>
    <cfif vDiaSem neq 1 and vDiaSem neq 7>
      <!--- verificar se Feriado Nacional --->
      <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
        SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
      </cfquery>
      <cfif rsFeriado.recordcount gt 0>
        <cfset nCont = nCont - 1>
      </cfif>
    </cfif>
    <!--- Verifica se final de semana  --->
    <cfif vDiaSem eq 1 or vDiaSem eq 7>
      <cfset nCont = nCont - 1>
    </cfif>
    <cfset nCont = nCont + 1>
  </cfloop>
<!---
<cfelse>
  <!--- 30 dias úteis na data de previsão --->
  <cfset nCont = 1>
  <cfloop condition="nCont lte 30">
    <cfset auxdtprev = DateAdd( "d", 1, auxdtprev)>
    <cfset vDiaSem = DayOfWeek(auxdtprev)>
    <cfif vDiaSem neq 1 and vDiaSem neq 7>
      <!--- verificar se Feriado Nacional --->
      <cfquery name="rsFeriado" datasource="#dsn_inspecao#">
        SELECT Fer_Data FROM FeriadoNacional where Fer_Data = #auxdtprev#
      </cfquery>
      <cfif rsFeriado.recordcount gt 0>
        <cfset nCont = nCont - 1>
      </cfif>
    </cfif>
    <!--- Verifica se final de semana  --->
    <cfif vDiaSem eq 1 or vDiaSem eq 7>
      <cfset nCont = nCont - 1>
    </cfif>
    <cfset nCont = nCont + 1>
  </cfloop>            
</cfif>
--->

<cfquery name="rsItemReanalisado" datasource="#dsn_inspecao#">
      SELECT RIP_Resposta, RIP_NumGrupo, RIP_NumItem FROM Resultado_Inspecao 
      WHERE RTRIM(RIP_Recomendacao)='R' AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsVerifValidados">
  SELECT RIP_Resposta, RIP_Recomendacao,Itn_ValidacaoObrigatoria 
  FROM ((Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
  INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND 
  (INP_Unidade = RIP_Unidade)) 
  INNER JOIN Itens_Verificacao ON (Itn_Ano = convert(char(4),RIP_Ano)) and (RIP_NumItem = Itn_NumItem) 
  AND (RIP_NumGrupo = Itn_NumGrupo) AND (Und_TipoUnidade = Itn_TipoUnidade) AND
  (INP_Modalidade = Itn_Modalidade) 
  WHERE (((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V')) AND 
  (RTRIM(RIP_Recomendacao) is NULL) AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and RIP_Unidade='#qryPapelTrabalho.RIP_Unidade#' 
</cfquery>

<cfset emReavaliacaoReavaliado = "#rsItemEmReanalise.recordcount#" + "#rsItemReanalisado.recordcount#" >

<!---inspeçoes NA = não avaliadas, ER = em reavaliação, RA =reavaliado, CO = concluida--->
<cfquery name="rsInspecaoNaoFinalizada" datasource="#dsn_inspecao#">
    SELECT INP_DTConcluirRevisao, INP_Situacao, INP_DtUltAtu, Pos_Situacao_Resp  FROM Inspecao
    LEFT JOIN  ParecerUnidade ON INP_NumInspecao = Pos_Inspecao
    WHERE LTRIM(INP_Situacao)<>'CO' 
      and INP_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and INP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#'
</cfquery>

<!--- controle das transações em tela --->
<!--- Valida itens individuais (todos os Não VERIFICADO e os Não EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1 ) --->
<cfif isDefined("form.acao") and '#form.acao#' is 'validarItem'>
  <cfoutput>
      <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
      <cfif listfind('#qryPapelTrabalho.Itn_PTC_Seq#','10')>
        <cfset RIPCaractvlr = 'QUANTIFICADO'>
      </cfif>	
      <cfquery datasource="#dsn_inspecao#">
        UPDATE Resultado_Inspecao SET 
        RIP_Recomendacao = 'V'
        , RIP_Caractvlr = '#RIPCaractvlr#'
        , RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
        , RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)
        WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#' and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
        and RIP_NumGrupo ='#form.grupo#' and RIP_NumItem='#form.item#'
      </cfquery>
      <cfif trim(qryPapelTrabalho.INP_RevisorLogin) lte 0>
        <cfquery datasource="#dsn_inspecao#">
          UPDATE Inspecao SET INP_RevisorLogin = '#CGI.REMOTE_USER#', INP_RevisorDTInic = CONVERT(varchar, getdate(), 120)
          WHERE INP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'and INP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
        </cfquery>
      </cfif>
      <!--- Atualizar dados na tela --->
      <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
        method="geraPapelTrabalho" returnvariable="qryPapelTrabalho">
      </cfinvoke>
      <script>
          <cfoutput>
            var insp = '#qryPapelTrabalho.INP_NumInspecao#';
            var grpitm = '###form.grupo#' + '.#FORM.item#';
          </cfoutput>
          var url = 'papeltrabalho.cfm?pg=controle&Form.id=' + insp + grpitm;
          window.open(url, '_self');
      </script>
  </cfoutput>    
</cfif>

  <!--- Concluir Revisão para todos os grupos/itens com Não Conformidades - NC --->
  <cfif isDefined("form.acao") and '#form.acao#' is 'ConcluirRevisaoSemNC'>
    <cfoutput>
        <cfset RIPCaractvlr = 'NAO QUANTIFICADO'>
      <cfif listfind('#qryPapelTrabalho.Itn_PTC_Seq#','10')>
        <cfset RIPCaractvlr = 'QUANTIFICADO'>
      </cfif>	
        <cfquery datasource="#dsn_inspecao#">
            UPDATE Resultado_Inspecao SET 
            RIP_Recomendacao = 'V'
            , RIP_Caractvlr = '#RIPCaractvlr#'
            , RIP_UserName_Revisor = '#CGI.REMOTE_USER#'
            , RIP_DtUltAtu_Revisor = CONVERT(char, GETDATE(), 120)           
            WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
        </cfquery>
        <cfquery datasource="#dsn_inspecao#">
            UPDATE Inspecao SET INP_Situacao = 'CO'
            , INP_UserName = '#CGI.REMOTE_USER#'
            , INP_DTUltAtu = CONVERT(varchar, getdate(), 120)
            , INP_DTConcluirRevisao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
            WHERE INP_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and INP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
        </cfquery>
        <cfquery datasource="#dsn_inspecao#">
            UPDATE ProcessoParecerUnidade SET Pro_Situacao = 'EN', Pro_DtEncerr = convert(varchar, getdate(), 102), Pro_userName = '#CGI.REMOTE_USER#', Pro_dtultatu = CONVERT(DATETIME, getdate(), 103)
            WHERE Pro_Unidade = '#qryPapelTrabalho.RIP_Unidade#'	and Pro_Inspecao ='#qryPapelTrabalho.INP_NumInspecao#'
        </cfquery>
        <cflocation url="../../../Pacin_ClassificacaoUnidades.cfm?&pagretorno=GeraRelatorio/gerador/dsp/papeltrabalho.cfm&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#">    
    </cfoutput>      
  </cfif>
<!--- inicio liberar avaliação para o gestor da unidade --->
<!---Verifica se esta inspeção possui algum item Em Revisao --->	
<cfquery name="qInspecaoLiberada" datasource="#dsn_inspecao#">
  SELECT * FROM ParecerUnidade 
  WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 0
</cfquery>
<!---Verifica se esta inspeção possui algum item em Reanálise --->
<cfquery datasource="#dsn_inspecao#" name="qVerifEmReanalise">
  SELECT RIP_Resposta, RIP_Recomendacao FROM Resultado_Inspecao 
  WHERE (RTRIM(RIP_Recomendacao)='S' OR RTRIM(RIP_Recomendacao)='R') and RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' 
</cfquery>
<!---Verifica se avaliação possui algum item não avaliado (todos os Não VERIFICADO e os Não EXECUTA em que o campo Itn_ValidacaoObrigatoria for igual a 1) --->
<cfquery datasource="#dsn_inspecao#" name="qVerifValidados">
  SELECT RIP_Resposta, RIP_Recomendacao 
  FROM ((Unidades INNER JOIN Inspecao ON Und_Codigo = INP_Unidade) 
  INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
  INNER JOIN Itens_Verificacao ON (Itn_Ano = convert(char(4),RIP_Ano)) AND 
              (RIP_NumItem = Itn_NumItem) AND 
              (RIP_NumGrupo = Itn_NumGrupo) AND 
              (Und_TipoUnidade = Itn_TipoUnidade) AND 
              (INP_Modalidade = Itn_Modalidade) 
  WHERE 
    ((RTRIM(RIP_Resposta)= 'E' AND Itn_ValidacaoObrigatoria=1) OR RTRIM(RIP_Resposta)= 'V') AND 
    RTRIM(RIP_Recomendacao) IS NULL AND RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and RIP_Unidade='#qryPapelTrabalho.RIP_Unidade#' 
</cfquery>

<!--- inicio re-envio de email conclusão de revisão --->
<cfoutput>
  <cfif isDefined("form.acao") and '#form.acao#' is 'reenvioemailconclusaorevisao'>
  </cfif> 
</cfoutput>  
<!--- final re-envio de email conclusão de revisão --->
<cfoutput>
  <cfif isDefined("form.acao") and '#form.acao#' is 'ConcluirRevisaoComNC'>
      <!---Inicio do processo de liberação da avaliação--->  
      <!---    <cfif qInspecaoLiberada.recordCount eq 0 and qVerifEmReanalise.recordCount eq 0 and qVerifValidados.recordCount eq 0> --->
      <!---Salva a matricula do gestor na tabela Inspecao para sinalisar o gestor que liberou a verificação --->
      <cfquery datasource="#dsn_inspecao#">
        UPDATE Inspecao SET INP_Situacao = 'CO'
        , INP_UserName = '#CGI.REMOTE_USER#'
        , INP_DtEncerramento = convert(varchar, getdate(), 102)
        , INP_DTUltAtu = CONVERT(varchar, getdate(), 120)
        , INP_DTConcluirRevisao = #createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
        WHERE INP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'
      </cfquery>

      <cfquery name="rs11" datasource="#dsn_inspecao#">
        SELECT RIP_REINCINSPECAO, RIP_Falta, RIP_Sobra, RIP_EmRisco, Und_TipoUnidade, Und_Centraliza, Itn_TipoUnidade, Pos_Unidade, Pos_NumGrupo, Pos_NumItem, Pos_Area, Pos_NomeArea, Itn_Pontuacao, Itn_Classificacao, Itn_PTC_Seq
        FROM (((Inspecao 
        INNER JOIN Resultado_Inspecao ON (INP_NumInspecao = RIP_NumInspecao) AND (INP_Unidade = RIP_Unidade)) 
        INNER JOIN ParecerUnidade ON (RIP_NumItem = Pos_NumItem) AND (RIP_NumGrupo = Pos_NumGrupo) AND (RIP_NumInspecao = Pos_Inspecao) AND (RIP_Unidade = Pos_Unidade)) 
        INNER JOIN Itens_Verificacao ON (convert(char(4),RIP_Ano) = Itn_Ano) AND (INP_Modalidade = Itn_Modalidade) AND (Pos_NumItem = Itn_NumItem) AND (Pos_NumGrupo = Itn_NumGrupo)) 
        INNER JOIN Unidades ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Pos_Unidade = Und_Codigo)
        WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 11
      </cfquery>
      <cfset startTime = CreateTime(0,0,0)> 
      <cfset endTime = CreateTime(0,0,45)> 
      <cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
      </cfloop>         
      <cfloop query="rs11">
          <cfset auxposarea = rs11.Pos_Area>
          <cfset auxnomearea = rs11.Pos_NomeArea>
          <cfif (rs11.Und_Centraliza neq "") and (rs11.Itn_TipoUnidade eq 4)>
              <cfquery name="rsCDD" datasource="#dsn_inspecao#">
              SELECT Und_Descricao FROM Unidades WHERE Und_Codigo = '#rs11.Und_Centraliza#'
              </cfquery>
              <cfset auxposarea = rs11.Und_Centraliza>
              <cfset auxnomearea = rsCDD.Und_Descricao>
          </cfif>
          <!--- inicio classificacao do ponto --->
          <cfset composic = rs11.Itn_PTC_Seq>	
          <cfset ItnPontuacao = rs11.Itn_Pontuacao>
          <cfset ClasItem_Ponto = ucase(trim(rs11.Itn_Classificacao))>
                        
          <cfset impactosn = 'N'>
          <cfif left(composic,2) eq '10'>
            <cfset impactosn = 'S'>
          </cfif>
          <!--- <cfset pontua = ItnPontuacao> --->
          <cfset fator = 1>
          <cfif impactosn eq 'S'>
            <cfset somafaltasobra = rs11.RIP_Falta>
            <cfif (rs11.Pos_NumItem eq 1 and (rs11.Pos_NumGrupo eq 53 or rs11.Pos_NumGrupo eq 72 or rs11.Pos_NumGrupo eq 214 or rs11.Pos_NumGrupo eq 284))>
					      <cfset somafaltasobra = somafaltasobra + rs11.RIP_Sobra>
				    </cfif>
            <cfif somafaltasobra gt 0>
              <cfloop query="rsRelev">
                  <cfif rsRelev.VLR_FaixaInicial is 0 and rsRelev.VLR_FaixaFinal lte somafaltasobra>
                  <cfset fator = rsRelev.VLR_Fator>
                  <cfelseif rsRelev.VLR_FaixaInicial neq 0 and VLR_FaixaFinal neq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial and somafaltasobra lte rsRelev.VLR_FaixaFinal>
                  <cfset fator = rsRelev.VLR_Fator>									
                  <cfelseif VLR_FaixaFinal eq 0 and somafaltasobra gt rsRelev.VLR_FaixaInicial>
                  <cfset fator = rsRelev.VLR_Fator> 								
                  </cfif>
              </cfloop>
            </cfif>	
          </cfif>	
          <cfset ItnPontuacao =  (ItnPontuacao * fator)>
          <cfif impactosn eq 'S'>
              <!--- Ajustes para os campos: Pos_ClassificacaoPonto --->
              <!--- Obter a pontuacao max pelo ano e tipo da unidade --->
              <cfquery name="rsPtoMax" datasource="#dsn_inspecao#">
                SELECT TUP_PontuacaoMaxima 
                FROM Tipo_Unidade_Pontuacao 
                WHERE TUP_Ano = '#right(qryPapelTrabalho.INP_NumInspecao,4)#' AND TUP_Tun_Codigo = #rs11.Itn_TipoUnidade#
              </cfquery> 
              <!--- calcular o perc de classificacao do item --->	
              <cfset PercClassifPonto = NumberFormat(((ItnPontuacao / rsPtoMax.TUP_PontuacaoMaxima) * 100),999.00)>	
              
              <!--- calculo da descricao do item a saber GRAVE, MEDIANO ou LEVE --->
              <cfif PercClassifPonto gt 50.01>
                <cfset ClasItem_Ponto = 'GRAVE'> 
              <cfelseif PercClassifPonto gt 10 and PercClassifPonto lte 50.01>
                <cfset ClasItem_Ponto = 'MEDIANO'> 
              <cfelseif PercClassifPonto lte 10>
                <cfset ClasItem_Ponto = 'LEVE'> 
              </cfif>	
          </cfif>		

          <!--- Update na tabela parecer unidade --->
          <cfquery datasource="#dsn_inspecao#">
            UPDATE ParecerUnidade SET Pos_Area = '#auxposarea#'
            , Pos_NomeArea = '#auxnomearea#'
            , Pos_Situacao_Resp = 14
            , Pos_Situacao = 'NR'
            , Pos_DtPosic = convert(varchar, getdate(), 102)
            , Pos_DtPrev_Solucao = #createodbcdate(createdate(year(auxdtprev),month(auxdtprev),day(auxdtprev)))#
            , Pos_DtUltAtu = CONVERT(varchar, GETDATE(), 120) 
            , pos_username = '#CGI.REMOTE_USER#' 
            , Pos_PontuacaoPonto=#ItnPontuacao#
            , Pos_ClassificacaoPonto='#ClasItem_Ponto#'
            , Pos_Sit_Resp_Antes = 11
            WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' and Pos_NumGrupo = #rs11.Pos_NumGrupo# and Pos_NumItem = #rs11.Pos_NumItem# and Pos_Situacao_Resp = 11
          </cfquery>
          <cfset startTime = CreateTime(0,0,0)> 
          <cfset endTime = CreateTime(0,0,45)> 
          <cfloop from="#startTime#" to="#endTime#" index="i" step="#CreateTimeSpan(0,0,0,1)#"> 
          </cfloop>             
          <!--- Inserindo dados dados na tabela Andamento --->
          <cfset andparecer = 'Ação: Concluir Revisao Com NC (GESTORES)'>
          <cfquery name="rsExisteSN" datasource="#dsn_inspecao#">
            select And_Unidade from Andamento 
            where And_Unidade = '#rs11.Pos_Unidade#' and 
            And_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and 
            And_NumGrupo=#rs11.Pos_NumGrupo# and 
            And_NumItem = #rs11.Pos_NumItem# and 
            And_HrPosic = '000014' and 
            And_Situacao_Resp = 14
          </cfquery>
          <cfif rsExisteSN.recordcount lte 0>
            <cfquery datasource="#dsn_inspecao#">
              insert into Andamento (And_NumInspecao, And_Unidade, And_NumGrupo, And_NumItem, And_DtPosic, And_username, And_Situacao_Resp, And_HrPosic, and_Parecer, And_Area, And_NomeArea) 
              values ('#qryPapelTrabalho.INP_NumInspecao#', '#rs11.Pos_Unidade#', #rs11.Pos_NumGrupo#, #rs11.Pos_NumItem#, convert(varchar, getdate(), 102), '#CGI.REMOTE_USER#', 14, '000014', '#andparecer#', '#rs11.Pos_Unidade#','#auxnomearea#')
            </cfquery>
          <cfelse>
            <cfquery datasource="#dsn_inspecao#">
              update Andamento set And_DtPosic=#createodbcdate(CreateDate(Year(Now()),Month(Now()),Day(Now())))#
              , And_username='#CGI.REMOTE_USER#'
              , And_Area = '#rs11.Pos_Unidade#'
              , and_Parecer= '#andparecer#'
              where And_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#' and 
              And_Unidade='#rs11.Pos_Unidade#' and 
              And_NumGrupo=#rs11.Pos_NumGrupo# and 
              And_NumItem=#rs11.Pos_NumItem# and
              And_Situacao_Resp=14 and
              And_HrPosic='000014'
            </cfquery>            
          </cfif>
      </cfloop>    
      <cflocation url="../../../Pacin_ClassificacaoUnidades.cfm?&pagretorno=GeraRelatorio/gerador/dsp/papeltrabalho.cfm&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#">             
	    <!--- </cfif>  --->
      <!---Fim do prcesso de liberação da avaliação--->
      <script language="javascript" >
        //    alert('Item validado com sucesso!');
        //   window.open(window.location,'_self');
      </script>
		  <!--- fim Verificação dos registros que estão na situação 14(não Respondido) na tabela ParecerUnidade --->
      <!--- Atualizar dados na tela --->
      <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
	      method="geraPapelTrabalho" returnvariable="qryPapelTrabalho">
      </cfinvoke>        			
  </cfif>
</cfoutput>   
<!--- fim liberar avaliação para o gestor da unidade --->
  
<!---Veirifica se esta inspeção possui algum item Em Revisão --->	
	<cfquery name="qInspecaoEmRevisao" datasource="#dsn_inspecao#">
		SELECT * FROM ParecerUnidade 
		WHERE Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#' AND Pos_Situacao_Resp = 0
	</cfquery>

  <cfset semNCvalidado = false>
   <!---Verifica se é uma verifcação não tem itens não conforme e se foi validada--->
  <cfquery datasource="#dsn_inspecao#" name="rsSemNC">
			SELECT Count(RIP_NumInspecao) as total, Count(CASE WHEN LTRIM(RTRIM(RIP_Recomendacao))='V' THEN 1 END) AS validado
      ,Count(CASE WHEN LTRIM(RTRIM(RIP_Resposta))='N' THEN 1 END) AS itemNC, Count(RIP_MatricAvaliador) as totalAvaliadores
      FROM  Resultado_Inspecao
			WHERE RIP_Unidade = '#qryPapelTrabalho.RIP_Unidade#' and RIP_NumInspecao ='#qryPapelTrabalho.INP_NumInspecao#'  
  </cfquery>

  <!---FIM - Verifica se é uma verificação sem itens não conforme--->
  <cfif "#rsSemNC.total#" eq "#rsSemNC.validado#" >
    <cfset semNCvalidado = true>
  </cfif>

  <cfquery name="rsConcluirAvaliacao" datasource="#dsn_inspecao#">
    SELECT Fun_Matric, Fun_Nome FROM Funcionarios
    WHERE Fun_Matric = '#qryPapelTrabalho.INP_Coordenador#'
  </cfquery> 
  <cfquery name="rsLiberadaValidadaPor" datasource="#dsn_inspecao#">
    SELECT Usu_Matricula, Usu_Apelido
    FROM Usuarios
    WHERE Usu_Login = '#qryPapelTrabalho.INP_Username#'
  </cfquery>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="pt-br">
<head>
<title>Sistema Nacional de Controle Interno</title>
<link href="../../../css.css" rel="stylesheet" type="text/css" />
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfif structKeyExists(url,'pg') and '#url.pg#' eq 'controle' and "#rsItemEmReanalise.recordcount#" neq 0>
    <meta http-equiv="refresh" content="60">
</cfif>
  <script language="javascript" >
   
    //captura a posição do scroll (usado nos botoes que chamam outras páginas)
    //e salva no sessionStorage
    function capturaPosicaoScroll() {
      sessionStorage.setItem('scrollpos', document.body.scrollTop);
    }

    //apos o onload recupera a posição do scroll armazenada no sessionStorage e reposiciona-o conforme ultima localização
    window.onload = function () {
      var scrollpos = sessionStorage.getItem('scrollpos');
      if (scrollpos) window.scrollTo(0, scrollpos);
      sessionStorage.setItem('scrollpos', '0');
      capturaPosicaoScroll();
    };

    //ao fechar, atualiza a página de controle de verificações
    window.onbeforeunload = function () {
      window.opener.location.reload();
    }

    function aguarde(t) {

      if (t !== undefined) {
        topo = 30 + document.getElementById(t).offsetTop;
      } else {
        topo = '200';
      }

      if (document.getElementById("aguarde").style.visibility == "visible") {
        document.getElementById("aguarde").style.visibility = "hidden";
        document.getElementById("main_body").style.cursor = 'auto';
      } else {
        document.getElementById("main_body").style.cursor = 'progress';
        document.getElementById("aguarde").style.visibility = "visible";
        piscando();

      }

      document.getElementById("imgAguarde").style.top = topo + 'px';
    }


    function abrirPopup(url, w, h) {

      var newW = w + 100;
      var newH = h + 100;
      var left = (screen.width - newW) / 2;
      var top = (screen.height - newH) / 2;
      var newwindow = window.open(url, '_blank', 'width=' + newW + ',height=' + newH + ',left=' + left + ',top=' + top + ',scrollbars=yes');
      newwindow.resizeTo(newW, newH);

      //posiciona o popup no centro da tela
      newwindow.moveTo(left, top);
      newwindow.focus();

    }

    //para botao voltar ao topo
    window.onscroll = function () {
      scrollFunction()
    };

    window.requestAnimFrame = (function () {
      return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        function (callback) {
          window.setTimeout(callback, 5000 / 60);
        };
    })();

    function scrollToY(scrollTargetY, speed, easing) {
      // scrollTargetY: the target scrollY property of the window
      // speed: time in pixels per second
      // easing: easing equation to use

      var scrollY = window.scrollY || document.documentElement.scrollTop,
        scrollTargetY = scrollTargetY || 0,
        speed = speed || 3000,
        easing = easing || 'easeOutSine',
        currentTime = 0;

      // min time .1, max time .8 seconds
      var time = Math.max(.1, Math.min(Math.abs(scrollY - scrollTargetY) / speed, .8));
      var easingEquations = {
        easeOutSine: function (pos) {
          return Math.sin(pos * (Math.PI / 2));
        },
        easeInOutSine: function (pos) {
          return (-0.5 * (Math.cos(Math.PI * pos) - 1));
        },
        easeInOutQuint: function (pos) {
          if ((pos /= 0.5) < 1) {
            return 0.5 * Math.pow(pos, 5);
          }
          return 0.5 * (Math.pow((pos - 2), 5) + 2);
        }
      };

      // add animation loop
      function tick() {
        currentTime += 1 / 60;

        var p = currentTime / time;
        var t = easingEquations[easing](p);

        if (p < 1) {
          requestAnimFrame(tick);

         window.scrollTo(0, scrollY + ((scrollTargetY - scrollY) * t));
        } else {
          window.scrollTo(0, scrollTargetY);
        }

      }

      // call it once to get started
      tick();
    }

    function scrollFunction() {
      capturaPosicaoScroll();
      if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
        document.getElementById("subDiv").style.display = "block";
      } else {
        document.getElementById("subDiv").style.display = "none";
      }

    }
    //fim script botão voltar ao topo
		function avisorevisor() {
			<cfoutput>
				let loginusuario = '#trim(cgi.REMOTE_USER)#';
				let loginrevisor = '#trim(qryPapelTrabalho.INP_RevisorLogin)#';
				let revisornome = '#trim(rsRevis.Usu_Apelido)#';
			</cfoutput>
			if (loginrevisor.length > 0 && loginusuario != loginrevisor){
				  alert('Revisor(a), Avaliação está no Status de Revisão pelo gestor(a): '+revisornome)
			}
		}  

  </script>


</head>
<cfset qtdrevisar = 0>
<cfset qtdvalidar = 0>

<body id="main_body" style="background:#fff" onload="avisorevisor()">

<div id="aguarde" name="aguarde" align="center"  style="width:100%;height:200%;top:0px;left:0px; background:transparent;
filter:progid:DXImageTransform.Microsoft.gradient(startColorstr=#7F86b2ff,endColorstr=#7F86b2ff);
z-index:1000;visibility:hidden;position:absolute;" >		
		 <img id="imgAguarde" name="imgAguarde" src="figuras/aguarde.png" width="100px"  border="0" style="position:absolute;"></img>
</div>
<cfset exibirSN = 'S'>
  <form id="formPT"  name="formPT" method="post">
      <input type="hidden" id="grupo" name="grupo" value="">
      <input type="hidden" id="item" name="item" value="">

      <div id="mainDiv" align="right" class="noprint">
        <div id="subDiv">
        <a onClick="scrollToY(0, 10000, 'easeInOutSine');" style="cursor:pointer"><img   alt="Ir para o topo da página" src="../../../figuras/topo.png" width="50"   border="0" ></img>
        <br>
        <span style="background-color:#fff;color:darkblue;position:relative;left:-8px;top:-7px">Topo</span></a>
        </div>
      </div>
      <table border="0" widtd="100%">
        <cfif qryPapelTrabalho.recordcount is 0>
        <tr>
          <td  valign="baseline" bordercolor="999999" bgcolor="" class="red_titulo"><div align="center"><span class="style2">Caro colaborador não há registros para Avaliação solicitada</span></div></td>
        </tr>
      </table>
        <cfabort>
        </cfif>
          <tr class="noprint">
            <th colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row"><input type="button" class="botao" onClick="window.close()" value="Fechar"></th>
          </tr> 
        <tr>
          <td widtd="22%" rowspan="2"><div align="left"></div></td>
        </tr>
        <table widtd="100%" border="0" cellspacing="4">
          <tr>
            <td colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row"></td>
          </tr>

          <tr>
            <td colspan="2" rowspan="2" valign="top" bordercolor="999999" bgcolor="" scope="row"><span class="labelcell"><img src="../../geral/img/logoCorreios.gif" alt="Logo ECT" width="148" height="33" align="left" /></span></td>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center"><span class="style2">DEPARTAMENTO DE CONTROLE INTERNO</span></div></td>
          </tr>
          <tr>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="center"> <span class="style2">PAPEL DE TRABALHO</span> </div></td>
          </tr>
          <tr>
            <td width="4" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th width="155" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Superintendência:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#qryPapelTrabalho.Dir_Descricao#</cfoutput></div></td>
          </tr>
           <tr>
            <td widtd="1%" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Unidade:</div></th>
            <td width="450" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#qryPapelTrabalho.Und_Descricao#</cfoutput>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div></td>
			<cfset auxclaini = qryPapelTrabalho.TNC_ClassifInicio>
			<cfset auxclaatu = qryPapelTrabalho.TNC_ClassifAtual>			
            <td width="663" colspan="6" valign="top" bordercolor="999999" bgcolor="" scope="row">
			<table width="100%" border="0">
              <tr>
                <td width="25%" bordercolor="999999"> <div align="center">Classificação Inicial:</div></td>
                <td width="25%" bordercolor="999999"><div align="left"><cfoutput>#auxclaini#</cfoutput></div></td>
                <td width="23%" bordercolor="999999"> <div align="center">Classificação Atual:</div></td>
                <td width="27%" bordercolor="999999"><div align="left"><cfoutput>#auxclaatu#</cfoutput></div></td>
              </tr>
            </table>
			</td>
          </tr> 
		   <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Período da Avaliação:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#DateFormat(qryPapelTrabalho.INP_DtInicInspecao,'dd/mm/yyyy')#</cfoutput>
                    <label class="fieldcell"> a </label>
                    <cfoutput>#DateFormat(qryPapelTrabalho.INP_DtFimInspecao,'dd/mm/yyyy')#</cfoutput></div></td>
          </tr>
          <cfset Num_Insp = Left(qryPapelTrabalho.INP_NumInspecao,2) & '.' & Mid(qryPapelTrabalho.INP_NumInspecao,3,4) & '/' & Right(qryPapelTrabalho.INP_NumInspecao,4)>
          <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Nº da Avaliação:</div></th>
            <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="justify"><cfoutput>#Num_Insp#</cfoutput>
              <!---  <cfif '#rsSituacoes.recordCount#' neq 0 and '#rsSemNC.totalAvaliadores#' neq 0> --->
                    <cfif qryPapelTrabalho.INP_DTConcluirRevisao neq ''> 
                        <cfif '#rsInspecaoNaoFinalizada.recordcount#' eq 0 and rsVerifValidados.recordcount eq 0 and rsQuatEmRevisao.recordcount eq 0>
                          <cfset dataHora = '#DateFormat(qryPapelTrabalho.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#'>
                          &nbsp;&nbsp;<span style="font-family:arial;font-size:12px;color:blue"><strong>CONCLUSÃO DA AVALIAÇÃO</strong></span> <span style="font-family:arial;font-size:12px;color:blue"> (por: <strong><cfoutput>#rsConcluirAvaliacao.Fun_Nome# - em: #dataHora#)</cfoutput></strong></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                          <cfset dataHora = '#DateFormat(qryPapelTrabalho.INP_DTConcluirRevisao,"DD/MM/YYYY")#'>
                          <span style="font-family:arial;font-size:12px;color:blue"><strong>CONCLUSÃO DA REVISÃO</strong></span> <span style="font-family:arial;font-size:12px;color:blue"> (por: <strong><cfoutput>#rsLiberadaValidadaPor.Usu_Apelido# - em: #dataHora#)</cfoutput></strong></span>
                          <cfif structKeyExists(url,'pg') and '#url.pg#' eq 'controle' >
                            <script>
                                    var mens = 'Avaliação de Controle liberada para Manifestação da unidade:\n<cfoutput>#qryPapelTrabalho.Und_Descricao#</cfoutput>\n\nLiberação realizada por:\n<cfoutput>#trim(rsLiberadaValidadaPor.Usu_Apelido)#</cfoutput> em <cfoutput>#dataHora#</cfoutput>.'; 
                                      alert(mens);
                                  </script>
                          </cfif>
                          <cfset exibirSN = 'N'>
                        <cfelse>
                            <span class="noprint" style="font-family:arial;font-size:12px;color:red"><strong>AVALIAÇÃO NÃO LIBERADA</strong></span> <span class="noprint" style="font-family:arial;font-size:10px;color:red"> (Ainda existem itens EM REVISÃO ou EM REANÁLISE, REANALISADOS, NÃO VERIFICADO ou NÃO EXECUTA sem validação.)</span>
                        </cfif>
                    </cfif>
                    <cfif '#semNCvalidado#' is false and '#emReavaliacaoReavaliado#' eq 0 and '#rsSemNC.itemNC#' eq 0 and "#rsSemNC.totalAvaliadores#" neq 0>
                      <span class="noprint" style="font-family:arial;font-size:12px;color:red"><strong>AVALIAÇÃO SEM ITENS "NÃO CONFORME"</strong></span> <span class="noprint" style="font-family:arial;font-size:12px;color:red;"> - Prezado Gestor, após conferência de todos os itens desta Avaliação, valide-a clicando no bot&atilde;o no final desta p&aacute;gina.</span>
                      <cfelse>
                      <cfif '#rsSemNC.itemNC#' eq 0 and '#semNCvalidado#' is true and "#rsSemNC.totalAvaliadores#" neq 0>
                        <span style="font-family:arial;font-size:12px;color:blue"><strong>AVALIAÇÃO SEM ITENS "NÃO CONFORME" VALIDADA</strong></span> <span style="font-family:arial;font-size:10px;color:blue"> (por: <cfoutput>#rsLiberadaValidadaPor.Usu_Apelido#)</cfoutput></span>
                      </cfif>
                    </cfif>
                    <cfif #rsItemEmReanalise.recordcount# neq 0>
                      <div style="margin-bottom:10px"><span style="font-family:arial;margin-right:2px;background:red;color:#fff;padding:3px;font-size:14px;">EM REANÁLISE PELO INSPETOR:&nbsp;</span><cfoutput query="rsItemEmReanalise">
                          <button class="botaoCadReanalise botaoPT" style="position:relative;top:3px" onClick="location.href='###rsItemEmReanalise.RIP_NumGrupo#.#rsItemEmReanalise.RIP_NumItem#'" type="button">#rsItemEmReanalise.RIP_NumGrupo#.#rsItemEmReanalise.RIP_NumItem#</button>
                      </cfoutput></div>
                    </cfif>
                    <cfif ('#grpacesso#' eq 'GESTORES' or '#grpacesso#' eq 'DESENVOLVEDORES') and #rsItemReanalisado.recordcount# neq 0>
                      <div  class="noprint" ><span style="font-family:arial;margin-right:2px;background:darkred;color:#fff;padding:4px;font-size:14px;">REANALISADO PELO INSPETOR:&nbsp;</span><cfoutput query="rsItemReanalisado">
                          <button class="botaoCadReanalisado botaoPT" style="position:relative;top:2px;padding:2px" onClick="location.href='###rsItemReanalisado.RIP_NumGrupo#.#rsItemReanalisado.RIP_NumItem#'" type="button">#rsItemReanalisado.RIP_NumGrupo#.#rsItemReanalisado.RIP_NumItem#</button>
                      </cfoutput> </div>
                    </cfif>
            </div></td>
          </tr>
          <tr>
            <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
          <tr>
            <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
            <td colspan="9" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="10" valign="top" bordercolor="999999" bgcolor="CCCCCC" scope="row"><div align="left">&nbsp;</div></td>
          </tr>
             
          <cfset numGrav = 0>
          <cfset muitoGrav = 0>
          <cfset CP = 0>
          <cfoutput>	
           <!--- 
            <cfdump  var="#qryPapelTrabalho#">
            <cfabort>
            --->
          
						<cfquery dbtype="query" name="rsLink">
							SELECT GRP_CODIGO, ITN_NUMITEM FROM qryPapelTrabalho order by GRP_CODIGO, ITN_NUMITEM
						</cfquery>
            <div class="grpitmlinks noprint" align="left" style="background:black;">
                  <cfloop query="rsLink"> 
                    <a href="##GI#rsLink.GRP_CODIGO#.#rsLink.ITN_NUMITEM#" id="GI#rsLink.GRP_CODIGO##rsLink.ITN_NUMITEM#">[#rsLink.GRP_CODIGO#.#rsLink.ITN_NUMITEM#]&nbsp;</a> 
                  </cfloop>
            </div>  
         
        </cfoutput>
          <cfoutput query="qryPapelTrabalho" group="Grp_Codigo">
            <tr>
              <td valign="top" bordercolor="999999" bgcolor="" scope="row"><label class="labelcell"> </label>
                  <div align="left"></div></td>
              <th valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="left">GRUPO: #Grp_Codigo#</div></th>
              <td colspan="7" valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row"><div align="justify"><strong>#Grp_Descricao#</strong></div></td>
        
            </tr>
            <cfoutput>
              <tr>
                <td  colspan="10" valign="top" bordercolor="999999" bgcolor=""  scope="row">&nbsp;</td>
              </tr>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                <!---   ID para �ncora     --->
                <cfset grp = Grp_Codigo>
                <cfset Ite = Itn_NumItem>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div id="#Grp_Codigo#.#Itn_NumItem#" align="left">Item: #grp#.#ite#</div></th>
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"><strong>#Itn_Descricao#</strong></div><a name="GI#Grp_Codigo#.#Itn_NumItem#"></td>
              </tr>
             <tr>
            <cfset auxpontua = qryPapelTrabalho.Itn_Pontuacao>
            <cfset auxclassif = qryPapelTrabalho.Itn_Classificacao>
            <cfif len(trim(qryPapelTrabalho.Pos_ClassificacaoPonto)) gt 0>
              <cfset auxpontua = qryPapelTrabalho.Pos_PontuacaoPonto>
              <cfset auxclassif = qryPapelTrabalho.Pos_ClassificacaoPonto>
            </cfif>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                <!---   ID para �ncora     --->
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div id="#Grp_Codigo#.#Itn_NumItem#" align="left">Relevância Ponto: </div></th>
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Pontuação<strong>:&nbsp; #auxpontua# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</strong>Classificação<strong>: &nbsp;#auxclassif#</strong></div></td>
              </tr> 
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div id="#Grp_Codigo#.#Itn_NumItem#" align="left">Manchete:</div></th>
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><strong>#qryPapelTrabalho.RIP_Manchete#</strong></div></td>
              </tr>
              <cfif RIP_Resposta neq 'E'>
                <tr>
                  <td valign="top" bordercolor="999999" bgcolor="" scope="row" >&nbsp;</td>
				  <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" >
                  <cfif RIP_Resposta neq 'N'>
                    Justificativa:
                    <cfelse>
                    Não Conformidade:
                  </cfif>
				  </div></th>
                  <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><h5><div align="justify">#Replace(RIP_Comentario,'IMAGENS_AVALIACOES/','../../../IMAGENS_AVALIACOES/','ALL')#</div></h5></td>
                </tr>
                <cfif RIP_Resposta neq 'C' and RIP_Resposta neq 'V'>
                  <cfif '#trim(RIP_ReincInspecao)#' neq ''>
				            <cfset numReincInsp = Left(RIP_ReincInspecao,2) & '.' & Mid(RIP_ReincInspecao,3,4) & '/' & Right(RIP_ReincInspecao,4)>
                    <tr class="red_titulo">
                      <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="style2">Reincidência:</div></th>
                      <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><span class="style2">#numReincInsp#&nbsp;-&nbsp;#RIP_ReincGrupo#.#RIP_ReincItem#</span></td>
                    </tr>
                  </cfif>
                  <cfset falta = lscurrencyformat(RIP_Falta,'Local')>
                  <cfset sobra = lscurrencyformat(RIP_Sobra,'Local')>
                  <cfset emrisco = lscurrencyformat(RIP_EmRisco,'Local')>
                  <cfset total = '#RIP_Falta#' + '#RIP_Sobra#' + '#RIP_EmRisco#'>
                  <cfif listfind(#qryPapelTrabalho.Itn_ImpactarTipos#,'F') or listfind(#qryPapelTrabalho.Itn_ImpactarTipos#,'S') or listfind(#qryPapelTrabalho.Itn_ImpactarTipos#,'R')>
                  <!--- <cfif '#total#' gt 0> --->
                    <tr>
                      <td valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
                      <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Impacto Financeiro(Valor):</div></th>
                      <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><cfif listfind('#qryPapelTrabalho.Itn_ImpactarTipos#','F')>Falta: #falta#</cfif> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfif listfind('#qryPapelTrabalho.Itn_ImpactarTipos#','S')>Sobra: #sobra#</cfif>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cfif listfind('#qryPapelTrabalho.Itn_ImpactarTipos#','R')>Em Risco: #emrisco#</cfif></td>
                    </tr>
                  </cfif>
                </cfif>
                <cfif RIP_Resposta eq 'N'>
                  <cfset recom = Replace(RIP_Recomendacoes,"
                      ","<BR>" ,"All")>
                  <cfset recom = Replace(recom,"-----------------------------------------------------------------------------------------------------------------------","<BR>-----------------------------------------------------------------------------------------------------------------------<BR>" ,"All")>
                  <tr>
                    <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                    <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Orientações:</div></th>
                    <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><h5>#recom#</h5></td>
                  </tr>
                </cfif>
              </cfif>
              <tr>
                <cfif RIP_Resposta eq 'N'>
                  <cfset avaliacao = 'Não Conforme'>
                  <cfelseif RIP_Resposta eq 'E'>
                  <cfset avaliacao = 'Não Executa Tarefa'>
                  <cfelseif RIP_Resposta eq 'C'>
                  <cfset avaliacao = 'Conforme'>
                  <cfelseif RIP_Resposta eq 'V'>
                  <cfset avaliacao = 'Não Verificado'>
                </cfif>
                <cfquery name="qSituacao" datasource="#dsn_inspecao#">
        SELECT Pos_Situacao_Resp, Pos_NCISEI, Pos_NCISEI, STO_Codigo, STO_Descricao, STO_Cor FROM ParecerUnidade INNER JOIN Situacao_Ponto ON STO_Codigo = Pos_Situacao_Resp WHERE Pos_Unidade ='#qryPapelTrabalho.RIP_Unidade#' and Pos_NumGrupo ='#qryPapelTrabalho.Grp_Codigo#' and Pos_NumItem='#qryPapelTrabalho.Itn_NumItem#' and Pos_Inspecao='#qryPapelTrabalho.INP_NumInspecao#'
                </cfquery>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Avaliação:</div></th>
                <cfset SEI = "#trim(qSituacao.Pos_NCISEI)#">
                <cfset SEI = "#left(SEI,5)#" & '.' & "#mid(SEI,6,6)#" & '/' & "#mid(SEI,12,4)#" & '-' & "#right(SEI,2)#">
                <td colspan="7" valign="top" bordercolor="999999" bgcolor="" scope="row"><strong <cfif #RIP_Resposta# eq 'N'>style="color:red"</cfif>>#avaliacao#
                      <cfif '#trim(qSituacao.Pos_NCISEI)#' neq ''>
                        <span style="color:red">com NCI - Nº SEI: #SEI#</span>
                      </cfif>
                  </strong>
                    <cfquery name="qAvaliador" datasource="#dsn_inspecao#">
          SELECT Fun_Matric, Fun_Nome FROM Funcionarios WHERE Fun_Matric = '#RIP_MatricAvaliador#'
                    </cfquery>
                    <cfif #trim(RIP_MatricAvaliador)# neq ''>
						<cfset maskmatrusu = trim(qAvaliador.Fun_Matric)>
						<cfset maskmatrusu = left(maskmatrusu,1) & '.' &  mid(maskmatrusu,2,3) & '.***-' & right(maskmatrusu,1)> 
                        <span  style="margin-left:10px;color:black;font-size:12px">(Avaliado por: #maskmatrusu#-#trim(qAvaliador.Fun_Nome)#)</span>
                    </cfif>                </td>
              </tr>
              <cfif RIP_Resposta eq 'N' or '#TRIM(RIP_Recomendacao)#' neq ''>
                <tr class="noprint">
                  <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                  <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Situação:</div></th>
                  <td colspan="2" ><cfif '#qSituacao.recordcount#' neq 0>
                      <cfif '#qSituacao.STO_Codigo#' neq 0 and '#qSituacao.STO_Codigo#' neq 11>
                        <div style="margin-bottom:10px">
                        <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff"> #TRIM(qSituacao.STO_Descricao)# </span>
                      </cfif>
                      <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff">
                      <cfif '#qSituacao.STO_Codigo#' eq 11>
                        <div style="margin-bottom:10px">
                        <span class="noprint" style="background:blue;padding:2px;color:white">REVISADO</span>
                      </cfif>
                      </div>
                      </span>
                    </cfif>
                      <span class="noprint" style="background:###TRIM(qSituAcao.STO_Cor)#;padding:2px;color:##fff">
                      <cfif '#TRIM(RIP_Recomendacao)#' eq 'S'>
                        <div ><span style="font-family:arial;background:red;padding:2px;color:##fff">EM REANÁLISE PELO INSPETOR</span></div>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;"> <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();abrirPopup('../../../itens_controle_revisliber_reanalise.cfm?cancelar=s&pg=pt&ninsp=#qryPapelTrabalho.INP_NumInspecao#&unid=#qryPapelTrabalho.RIP_Unidade#&ngrup=#qryPapelTrabalho.Grp_Codigo#&nitem=#qryPapelTrabalho.Itn_NumItem#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#',600,650)">
                          <div><img alt="Cancelar Reanálise do item" src="../../../figuras/reavaliar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">Cancelar Reanálise</div>
                        </a> </div>
                      </cfif>
                      <cfif ('#grpacesso#' eq 'GESTORES' or '#grpacesso#' eq 'DESENVOLVEDORES')>
                        <cfif '#TRIM(RIP_Recomendacao)#' eq 'R'>
                          <div ><span class="noprint" style="font-family:arial;background:darkred;padding:2px;color:##fff">REANALISADO PELO INSPETOR</span></div>
                        </cfif>
                      </cfif>
                      <!--- Retirado do if abaixo para aparecer a palavra VALIDADO '#rsInspecaoNaoFinalizada.recordcount#' neq 0 and  --->
                      <cfif  (RIP_Resposta eq 'V' or (RIP_Resposta eq 'E' and '#Itn_ValidacaoObrigatoria#' eq 1)) and '#trim(RIP_Recomendacao)#' eq 'V' and  ('#rsVerifValidados.recordcount#' neq 0 or '#qInspecaoEmRevisao.recordcount#' neq 0)>
                        <div> <span class="noprint" style="font-family:arial;padding:4px;background:green;color:white">VALIDADO</span></div>
                      </cfif>
                    </span></td>
                </tr>
              </cfif>
              <cfif RIP_Resposta neq 'E'>
                <tr>
                  <td valign="top" bordercolor="999999" bgcolor=""></td>
                  <cfinvoke component="#vRelatorio#.GeraRelatorio.gerador.ctrl.controller"
                            method="geraAnexoNumero" returnvariable="qryAnexos">
                    <cfinvokeargument name="vNumInspecao" value="#qryPapelTrabalho.INP_NumInspecao#">
                    <cfinvokeargument name="vNumGrupo" value="#qryPapelTrabalho.Grp_Codigo#">
                    <cfinvokeargument name="vNumItem" value="#qryPapelTrabalho.Itn_NumItem#">
                  </cfinvoke>
                  <th bordercolor="999999" bgcolor=""><div align="left" id="anexo">Anexo:</div></th>
                  <td colspan="7" bordercolor="999999" bgcolor=""><div align="left" id="arquivo">
                      <cfloop query="qryAnexos">
                        <a target="_blank" href="../../../abrir_pdf_act.cfm?arquivo=#ListLast(qryAnexos.Ane_Caminho,'\')#"> <span class="link1">#ListLast(qryAnexos.Ane_Caminho,'\')#</span><br />
                        </a>
                      </cfloop>
                  </div></td>
                </tr>
              </cfif>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></th>
                <td colspan="2">
                <cfif ('#qSituacao.Pos_Situacao_Resp#' eq 0 or '#qSituacao.Pos_Situacao_Resp#' eq 11 or '#qSituacao.recordcount#' eq 0 or '#rsVerifValidados.recordcount#' neq 0 or '#rsSemNC.itemNC#' eq 0 or rsQuatEmRevisao.recordcount neq 0) and  '#TRIM(RIP_Recomendacao)#' neq 'S' and  ('#grpacesso#' eq 'GESTORES' or '#grpacesso#' eq 'DESENVOLVEDORES') and #trim(RIP_MatricAvaliador)# neq '' and structKeyExists(url,'pg') and '#url.pg#' eq 'controle'  >
                    <cfif '#rsInspecaoNaoFinalizada.recordcount#' neq 0 or '#rsVerifValidados.recordcount#' neq 0 or '#rsSemNC.itemNC#' eq 0 or rsQuatEmRevisao.recordcount neq 0>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;"> 
                          <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();abrirPopup('../../../itens_controle_revisliber_reanalise.cfm?pg=pt&ninsp=#qryPapelTrabalho.INP_NumInspecao#&unid=#qryPapelTrabalho.RIP_Unidade#&ngrup=#qryPapelTrabalho.Grp_Codigo#&nitem=#qryPapelTrabalho.Itn_NumItem#&tpunid=#qryPapelTrabalho.TUN_Codigo#&modal=#qryPapelTrabalho.INP_Modalidade#',600,650)">
                          <div><img alt="Enviar p/ Reanálise do Inspetor ou Validar Reanálise" src="../../../figuras/reavaliar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">
                            <cfif '#TRIM(RIP_Recomendacao)#' eq 'R'>
                              Validar Reanálise
                              <cfelse>
                              Reanalisar
                            </cfif>
                          </div>
                        </a> 
                        </div>
                        <cfif  (RIP_Resposta eq 'V' or (RIP_Resposta eq 'E' and '#Itn_ValidacaoObrigatoria#' eq 1)) and '#TRIM(RIP_Recomendacao)#' eq '' and '#rsSemNC.itemNC#' neq 0>
                          <cfif '#qSituacao.Pos_Situacao_Resp#' le 0 and '#rsQuatEmRevisao.quantEmRevisao#' le 0 and '#rsItemEmReanalise.recordcount#' le 0 and '#rsItemReanalisado.recordcount#' le 0 and '#rsVerifValidados.recordcount#' eq '1' >
                            <div class="noprint" align="center" style="margin-top:10px;margin-left:60px;float:left;">
                              <a style="cursor:pointer;"  onclick="if(confirm('Atenção! Após a validação, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e Não EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){document.formPT.acao.value = 'validarItem';document.formPT.grupo.value = '#qryPapelTrabalho.Grp_Codigo#';document.formPT.item.value = '#qryPapelTrabalho.Itn_NumItem#';document.formPT.submit();}">
                                <div><img alt="Validar Avaliação" src="../../../figuras/checkVerde.png" width="25" border="0" /></div>
                                <div style="color:darkred;position:relative;font-size:12px">Validar</div>
                              </a> 
                            </div>
                          <cfelse>
                            <div class="noprint" align="center" style="margin-top:10px;margin-left:60px;float:left;"><a style="cursor:pointer;"  onclick="if(confirm('Deseja validar a Avaliação deste item?')){document.formPT.acao.value = 'validarItem';document.formPT.grupo.value = '#qryPapelTrabalho.Grp_Codigo#';document.formPT.item.value = '#qryPapelTrabalho.Itn_NumItem#';document.formPT.submit();}">
                              <div><img alt="Validar Avaliação" src="../../../figuras/checkVerde.png" width="25" border="0" /></div>
                              <div style="color:darkred;position:relative;font-size:12px">Validar</div>
                            </a> 
                            </div>
                            <cfset qtdvalidar = qtdvalidar + 1>
                          </cfif>
                        </cfif>
                    </cfif>
                    <cfif ('#qSituacao.Pos_Situacao_Resp#' eq 0) and RIP_Resposta eq 'N' and  '#TRIM(RIP_Recomendacao)#' neq 'R'>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:60px" >
                        <cfif '#qSituacao.Pos_Situacao_Resp#' eq 0 and '#rsQuatEmRevisao.quantEmRevisao#' eq 1 and '#rsItemEmReanalise.recordcount#' eq 0 and '#rsItemReanalisado.recordcount#' eq 0 and '#rsVerifValidados.recordcount#' eq '0'>
                            <!---                                       <cfset M = M> --->
                            <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();if(window.confirm('Atenção! Após a revisão deste item, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){
                                         window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#','_self');}">
                            </a>   
                        </cfif>
                        
                          <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();if(window.confirm('Atenção! Após a revisão deste item, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){
                                         window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#','_self');}"><a style="cursor:pointer;"  onclick="capturaPosicaoScroll();window.open('../../../itens_controle_revisliber.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#','_self')">
                          <div ><img  alt="Revisar" src="../../../figuras/revisar.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">Revisar</div>
                          </a> </a></div>
                          
                          <cfset qtdrevisar = qtdrevisar + 1>
                        </cfif>
                    </cfif>  
                    <cfif RIP_Resposta eq 'C' or RIP_Resposta eq 'V'>
                        <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:60px" >
                          <a style="cursor:pointer;"  onclick="capturaPosicaoScroll();if(window.confirm('Atenção! Após a revisão deste item, esta Avaliação será liberada e não será possível revisar outros itens.\n\nClique em OK se todos os itens CONFORME e NÃO EXECUTA já tiverem sido revisados, caso contrário, clique em Cancelar e realize a revisão dos itens.')){
                                         window.open('../../../itens_controle_corrigir.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#','_self');}"><a style="cursor:pointer;"  onclick="capturaPosicaoScroll();window.open('../../../itens_controle_corrigir.cfm?pg=pt&Unid=#qryPapelTrabalho.RIP_Unidade#&Ninsp=#qryPapelTrabalho.INP_NumInspecao#&Ngrup=#qryPapelTrabalho.Grp_Codigo#&Nitem=#qryPapelTrabalho.Itn_NumItem#&situacao=#qSituAcao.Pos_Situacao_Resp#&vlrdec=#qryPapelTrabalho.Itn_ValorDeclarado#&modal=#qryPapelTrabalho.INP_Modalidade#&tpunid=#qryPapelTrabalho.TUN_Codigo#','_self')">
                          <div ><img  alt="Corrigir" src="../../../figuras/Corrigir.png" width="25"   border="0" /></div>
                          <div style="color:darkred;position:relative;font-size:12px">Corrigir</div>
                          </a> </a></div>
                    </cfif>                     
                  
                    </td>
              </tr>
              <tr>
                <td valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left" class="labelcell"></div></td>
                <td colspan="8"  valign="top" bordercolor="999999" bgcolor="F5F5F5" scope="row" style="height:6px"></td>
              </tr>
            </cfoutput>
            <tr>
              <td colspan="10" valign="top" bordercolor="999999" bgcolor="" scope="row" >&nbsp;</td>
            </tr>
          </cfoutput>
<!--- --->
          
          <cfquery name="rsBusca" datasource="#dsn_inspecao#">
            SELECT RIP_Unidade, RIP_NumInspecao, RIP_NumGrupo, RIP_NumItem, RIP_Resposta, RIP_Recomendacao, RIP_Falta, RIP_Sobra, RIP_EmRisco, RIP_ReincInspecao, RIP_ReincGrupo, RIP_ReincItem
            FROM Resultado_Inspecao
            WHERE RIP_NumInspecao='#qryPapelTrabalho.INP_NumInspecao#'
          </cfquery>       
          <cfset qtdc = 0>
          <cfset qtdn = 0>
          <cfset qtdv = 0>
          <cfset qtde = 0>
          <cfset qtdrecR = 0>
          <cfset qtdrecV = 0>
          <cfset qtdrecS = 0>
          <cfset falta = 0>
          <cfset sobra = 0>
          <cfset risco = 0>
          <cfset reincinde = 0>

          <cfquery dbtype="query" name="rsC">
            SELECT RIP_Resposta 
            FROM  rsBusca
            where RIP_Resposta = 'C'
          </cfquery>
          <cfquery dbtype="query" name="rsN">
            SELECT RIP_Resposta 
            FROM  rsBusca
            where RIP_Resposta = 'N'
          </cfquery>
          <cfquery dbtype="query" name="rsV">
            SELECT RIP_Resposta 
            FROM  rsBusca
            where RIP_Resposta = 'V'
          </cfquery>
          <cfquery dbtype="query" name="rsE">
            SELECT RIP_Resposta 
            FROM  rsBusca
            where RIP_Resposta = 'E'
          </cfquery>
          <cfquery dbtype="query" name="rsValidarReanalise">
            SELECT RIP_Recomendacao 
            FROM  rsBusca
            where RIP_Recomendacao = 'R'
          </cfquery>
          <cfquery dbtype="query" name="rsValidado">
            SELECT RIP_Recomendacao 
            FROM  rsBusca
            where RIP_Recomendacao = 'V'
          </cfquery>    
          <cfquery dbtype="query" name="rsCancelReanal">
            SELECT RIP_Recomendacao 
            FROM  rsBusca
            where RIP_Recomendacao = 'S'
          </cfquery>                  
          <cfquery dbtype="query" name="rsSomas">
          SELECT RIP_NumInspecao, Sum(RIP_Falta) AS ripFalta, Sum(RIP_Sobra) AS ripSobra, Sum(RIP_EmRisco) AS ripEmRisco
          FROM rsBusca
          GROUP BY RIP_NumInspecao
          </cfquery>
          <cfquery dbtype="query" name="rsReincide">
          SELECT RIP_ReincGrupo
          FROM rsBusca where RIP_ReincGrupo > 0
          </cfquery>  
<!---          --->   
      <table width="1000" border="1" align="center" class="exibir"> 
          <tr bgcolor="">
            <td><div align="center">Conforme</div></td>
            <td><div align="center">NãoConforme</div></td>
            <td><div align="center">NãoVerificado</div></td>
            <td><div align="center">NãoExecuta</div></td>
            <td><div align="center">Total</div></td>
            <td><div align="center">Validar</div></td>
            <td><div align="center">Validar_Reanálise</div></td>
            <td><div align="center">Validado</div></td>
            <td><div align="center">Cancel.Reanálise</div></td>    
            <td><div align="center">Revisar</div></td>                     
            <td><div align="center">Falta</div></td>
            <td><div align="center">Sobra</div></td>
            <td><div align="center">EmRisco</div></td>
			    <td><div align="center">Reincidentes</div></td>
          </tr>
      <cfoutput>
        <cfset qtdc = rsC.recordcount>
        <cfset qtdn = rsN.recordcount>
        <cfset qtdv = rsV.recordcount>
        <cfset qtde = rsE.recordcount>
        <cfset qtdrecR = rsValidarReanalise.recordcount>
        <cfset qtdrecV = rsValidado.recordcount>
        <cfset qtdrecS = rsCancelReanal.recordcount>
        <cfset falta = lscurrencyformat(rsSomas.ripFalta,'Local')>
        <cfset sobra = lscurrencyformat(rsSomas.ripSobra,'Local')>
        <cfset risco = lscurrencyformat(rsSomas.ripEmRisco,'Local')>
        <cfset reincinde = rsReincide.recordcount>     
        <tr bgcolor="" class="exibir">
          <td><div align="center">#qtdc#</div></td>
          <td><div align="center">#qtdn#</div></td>
          <td><div align="center">#qtdv#</div></td>
          <td><div align="center">#qtde#</div></td>
          <td><div align="center">#rsBusca.recordcount#</div></td>
          <td><div align="center">#qtdvalidar#</div></td>
          <td><div align="center">#qtdrecR#</div></td>
          <td><div align="center">#qtdrecV#</div></td>
          <td><div align="center">#qtdrecS#</div></td>
          <td><div align="center">#qtdrevisar#</div></td>
          <td><div align="center">#falta#</div></td>
          <td><div align="center">#sobra#</div></td>
          <td><div align="center">#risco#</div></td>
          <td><div align="center">#reincinde#</div></td>
        </tr>
      </cfoutput>
	  </table>  
 
        <cfif qInspecaoLiberada.recordCount eq 0 and qVerifEmReanalise.recordCount eq 0 and qVerifValidados.recordCount eq 0 and exibirSN eq 'S' and '#rsSemNC.itemNC#' neq 0>
          <br>
            <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:620px">
                <a style="cursor:pointer;"  onclick="if(confirm('Confirma Concluir Revisão e Liberar Avaliação para Gestor(a) da Unidade?')){document.formPT.acao.value='ConcluirRevisaoComNC';document.formPT.submit();}">
                <div ><img  alt="Liberar" src="../../../figuras/liberada.png" width="50" border="0" /></div>
                <div style="color:darkred;position:relative;font-size:25px">Concluir Revisão e Liberar Avaliação para Gestor(a) da Unidade</div>
                </a> 
                </div>      
          <br><br><br><br>          
        </cfif>    
        <cfif ('#semNCvalidado#' is false) and ('#emReavaliacaoReavaliado#' eq 0) and ('#rsSemNC.itemNC#' eq 0)>
          <!---
                <div align="center">
            <input name="submit" type="submit" type="button" class="botao" onClick="if(confirm('Deseja validar esta Avaliação sem itens NÃO CONFORME?\n\nTodos os itens foram analisados?')){document.formPT.acao.value = 'ConcluirRevisaoSemNC';}" value="Validar Avaliação sem Itens Não Conforme">
            </div>
          --->
          <br>
          <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:620px">
            <a style="cursor:pointer;" onClick="if(confirm('Confirma Concluir Revisão (Validar Avaliação sem Não Conformidades)?')){document.formPT.acao.value='ConcluirRevisaoSemNC';document.formPT.submit();}">
            <div ><img  alt="Liberar" src="../../../figuras/liberada.png" width="25" border="0" /></div>
            <div style="color:darkred;position:relative;font-size:25px">Concluir Revisão (Validar Avaliação sem Não Conformidades)</div>
            </a> 
          </div>   
          <br><br><br>  
        </cfif>	 
          <tr>
            <td bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
            <th colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left">Equipe:</div></th>
          </tr>
          <tr>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div></th>
            <th colspan="3" valign="top" bordercolor="999999" bgcolor="" scope="row"><div align="left"></div>
            Assinaturas:</th>
          </tr>
          <cfset mat = '#qryPapelTrabalho.INP_Coordenador#'>
          <tr>
            <th colspan="2" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
          </tr>
          <cfquery name="qInspetores" datasource="#dsn_inspecao#">
            SELECT Fun_Matric, Fun_Nome from Inspetor_Inspecao INNER JOIN Funcionarios ON Fun_Matric = IPT_MatricInspetor WHERE IPT_NumInspecao = '#qryPapelTrabalho.INP_NumInspecao#' ORDER BY Fun_Nome
          </cfquery>
          <cfoutput query= "qInspetores">
            <tr>
              <td valign="top" bordercolor="999999" bgcolor="">&nbsp;</td>
			  <!--- <cfset exibmatr = (Left(Fun_Matric,1) & '.' & Mid(Fun_Matric,2,3) & '.' & Mid(Fun_Matric,5,3) & '-' & Right(Fun_Matric,1)) & "   " & Fun_Nome> --->
			  <cfset exibmatr = (Left(Fun_Matric,1) & '.' & Mid(Fun_Matric,2,3) & '.***-' & Right(Fun_Matric,1)) & "   " & Fun_Nome>
			  <cfif '#mat#' eq '#Fun_Matric#'>
				<cfset exibmatr = exibmatr & "(COORDENADOR)">
			  </cfif>
			  
              <th colspan="4" valign="top" bordercolor="999999" bgcolor="">
			  <table width="100%" border="0">
                <tr>
                  <td width="51%">#exibmatr#</td>
                  <td width="49%">-------------------------------------------------------------------</td>
                </tr>
              </table>                   </th>
            </tr>
          </cfoutput>
          <tr>
            <th colspan="5" bordercolor="999999" bgcolor="">&nbsp;</th>
          </tr>
		   <tr>
            <th valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</th>
            <th colspan="4" valign="top" bordercolor="999999" bgcolor="" scope="row">
              <div align="center">
                <div align="right" style="position:relative;right:0px">
                  <table width="618" border="0" align="center">
                    <tr>
                      <td width="612"><div align="right">Data/Hora de Emissão: <cfoutput>#DateFormat(Now(),"DD/MM/YYYY")#</cfoutput> - <cfoutput>#TimeFormat(Now(),'HH:MM')#</cfoutput></div></td>
                    </tr>
                  </table>
                </div>
             </div></th>
          </tr>
        
   <!--- <cfif '#rsInspecaoNaoFinalizada.recordcount#' eq 0 and '#rsVerifValidados.recordcount#' eq 0 and '#qInspecaoEmRevisao.recordcount#' eq 0>  --->
    <cfif qryPapelTrabalho.INP_DTConcluirRevisao neq ''>         
          <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:690px">
            <tr class="noprint">
              <th colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row"><button type="button" onClick="window.print();">Imprimir</button></th>
            </tr>
          </div>            
    </cfif>
          <tr>
            <td colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row">&nbsp;</td>
          </tr>
          <div class="noprint" align="center" style="margin-top:10px;float: left;margin-left:690px">
            <th colspan="5" valign="top" bordercolor="999999" bgcolor="" scope="row"><strong><input type="button" class="botao" onClick="window.close()" value="Fechar"></strong></th>
          </tr> 
    </table>	
    <input type="hidden" id="acao" name="acao" value="">    
    <input type="hidden" id="id" name="id" value="<cfoutput>#qryPapelTrabalho.INP_NumInspecao#</cfoutput>"> 
  </form>
  <form name="formvalidar" method="get">
    <input type="hidden" id="pg" name="pg" value="controle">
    <input type="hidden" id="id" name="id" value="">
  </form>
</body>
<script>
 function irpara(a){
  alert('aqui 1168')
   window.open('GeraRelatorio/gerador/dsp/papeltrabalho.cfm?pg=controle&Form.idNinsp=1800052025+a','_self')>
 }
</script>
</html>