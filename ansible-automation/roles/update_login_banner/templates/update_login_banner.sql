set define ~;
DECLARE 
  vrecord_gid cp_gapcie_brimpl.b_ucie_welcome_msg.record_gid%type;
BEGIN
  select record_gid into vrecord_gid from cp_gapcie_brimpl.b_ucie_welcome_msg;
  update cp_gapcie_brimpl.b_ucie_welcome_msg set desc_tx='{{text}}' where cp_gapcie_brimpl.b_ucie_welcome_msg.record_gid=vrecord_gid;
END;
/
EXIT;
