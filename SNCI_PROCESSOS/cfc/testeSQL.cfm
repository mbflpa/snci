<cfprocessingdirective pageencoding="utf-8">
<cftransaction >
  <cfquery name="rsProcesso2024" datasource="#application.dsn_processos#" timeout="120">	
    Select * FROM pc_processos where pc_processo_id ='0100212024'
  </cfquery>

  <cfquery name="insertProcesso" datasource="#application.dsn_processos#" timeout="120">	
    INSERT INTO pc_processos
            (pc_processo_id
            ,pc_usu_matricula_cadastro
            ,pc_datahora_cadastro
            ,pc_num_sei
            ,pc_num_rel_sei
            ,pc_num_orgao_origem
            ,pc_num_orgao_avaliado
            ,pc_num_avaliacao_tipo
            ,pc_num_classificacao
            ,pc_data_inicioAvaliacao
            ,pc_num_status
            ,pc_alteracao_datahora
            ,pc_alteracao_login
            ,pc_usu_matricula_coordenador
            ,pc_modalidade
            ,pc_data_fimAvaliacao
            ,pc_data_finalizado
            ,pc_usu_matricula_coordenador_nacional
            ,pc_ano_pacin
            ,pc_tipo_demanda
            ,pc_aval_tipo_nao_aplica_descricao
            ,pc_iniciarBloqueado
            ,pc_indicadorSetorial)
      VALUES
            ('0100042025'
              ,'#rsProcesso2024.pc_usu_matricula_cadastro#'
              ,CAST('#rsProcesso2024.pc_datahora_cadastro#' AS DATETIME)
              ,'#rsProcesso2024.pc_num_sei#'
              ,'#rsProcesso2024.pc_num_rel_sei#'
              ,'#rsProcesso2024.pc_num_orgao_origem#'
              ,'#rsProcesso2024.pc_num_orgao_avaliado#'
              ,#rsProcesso2024.pc_num_avaliacao_tipo#
              ,#rsProcesso2024.pc_num_classificacao#
              ,'2025-01-02'  
              ,#rsProcesso2024.pc_num_status#
              ,CAST('#rsProcesso2024.pc_alteracao_datahora#' AS DATETIME)
              ,'#rsProcesso2024.pc_alteracao_login#'
              ,'#rsProcesso2024.pc_usu_matricula_coordenador#'
              ,'#rsProcesso2024.pc_modalidade#'
              ,CAST('#rsProcesso2024.pc_data_fimAvaliacao#' AS DATE)
              ,CAST('#rsProcesso2024.pc_data_finalizado#' AS DATE)
              ,'#rsProcesso2024.pc_usu_matricula_coordenador_nacional#'
              ,#rsProcesso2024.pc_ano_pacin#
              ,'#rsProcesso2024.pc_tipo_demanda#'
              ,'#rsProcesso2024.pc_aval_tipo_nao_aplica_descricao#'
              ,'#rsProcesso2024.pc_iniciarBloqueado#'
              ,'#rsProcesso2024.pc_indicadorSetorial#')
</cfquery>


  <cfquery name="updateAvaliacoes" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_avaliacoes
    SET pc_aval_processo = '0100042025'
    WHERE pc_aval_processo = '0100212024'
  </cfquery>

  <cfquery name="updateAvaliadores" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_avaliadores
    SET 
        pc_avaliador_id_processo = '0100042025'
  WHERE pc_avaliador_id_processo = '0100212024'
  </cfquery>

  <cfquery name="updateindEstrategicos" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_processos_indEstrategicos
      SET pc_processo_id = '0100042025'
      WHERE pc_processo_id ='0100212024'
  </cfquery>

  <cfquery name="updatemebitida" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_processos_mebitida
      SET pc_processo_id = '0100042025'
    WHERE pc_processo_id ='0100212024'
  </cfquery>

  <cfquery name="updatepc_processos_objEstrategicos" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_processos_objEstrategicos
      SET pc_processo_id = '0100042025'
    WHERE pc_processo_id ='0100212024'
  </cfquery>

  <cfquery name="updatepc_processos_riscosEstrategicos" datasource="#application.dsn_processos#" timeout="120">
    UPDATE pc_processos_riscosEstrategicos
      SET pc_processo_id = '0100042025'
    WHERE pc_processo_id ='0100212024'
  </cfquery>

  <cfquery name="deleteProcessos" datasource="#application.dsn_processos#" timeout="120">
    DELETE FROM pc_processos
    WHERE pc_processo_id = '0100212024'
  </cfquery>
</cftransaction>