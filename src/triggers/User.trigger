trigger User on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	UserTriggerHandler.getInstance().fire();
}