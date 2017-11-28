@IsTest
private class PermissionSetAssignmentManagerTest {

	@IsTest
	private static void addPermissionSetToUser () {

		User user = queryUserRecord();

		system.assertEquals(0, user.PermissionSetAssignments.size());

		PermissionSet testPS = [
			SELECT Id, Name
			FROM PermissionSet
			WHERE IsCustom = TRUE
			AND IsOwnedByProfile = FALSE
			LIMIT 1
		];

		system.assertNotEquals(null, testPS.Id);

		Test.startTest();

		user.PermissionSets__c = testPS.Name;
		update user;

		Test.stopTest();

		user = queryUserRecord(user.Id);

		system.assertEquals(1, user.PermissionSetAssignments.size());
	}

	@IsTest
	private static void removePermissionSetFromUser () {

		User user = queryUserRecord();

		system.assertEquals(0, user.PermissionSetAssignments.size());

		PermissionSet testPS = [
			SELECT Id, Name
			FROM PermissionSet
			WHERE IsCustom = TRUE
			AND IsOwnedByProfile = FALSE
			LIMIT 1
		];

		system.assertNotEquals(null, testPS.Id);

		user.PermissionSets__c = testPS.Name;
		update user;

		user = queryUserRecord(user.Id);

		system.assertEquals(1, user.PermissionSetAssignments.size());

		Test.startTest();

		user.PermissionSets__c = '';
		update user;

		Test.stopTest();
	}

	@TestSetup
	private static void setupTestData () {

		UserRole role = new UserRole(
			DeveloperName = 'PexlifyRole',
			Name = 'Pexlify Role'
		);
		insert role;

		insert new User(
			ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
			LastName = 'Pexlify',
			FirstName = 'John',
			Email = 'info@pexlify.com',
			Username = 'pexlify-' + system.now().year() + '-' + system.now().month() + '-' + system.now().day() + '-' + system.now().hour() + '-' + system.now().minute() + '-' + system.now().second() + '-testuser@pexlify.com',
			CompanyName = 'Pexlify',
			Title = 'TestUser',
			Alias = 'testUser',
			TimeZoneSidKey = 'Europe/Dublin',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_IE',
			UserRoleId = role.Id
		);
	}

	private static User queryUserRecord () {
		return queryUserRecord(null);
	}

	private static User queryUserRecord (Id userId) {

		return (userId == null) 
			? [SELECT Id, PermissionSets__c,
					(Select Id, PermissionSetId, AssigneeId
					From PermissionSetAssignments
					Where PermissionSet.IsCustom = TRUE
					And PermissionSet.IsOwnedByProfile = FALSE)
				FROM User
				WHERE Email = 'info@pexlify.com'
				LIMIT 1]
			: [SELECT Id, PermissionSets__c,
					(Select Id, PermissionSetId, AssigneeId
					From PermissionSetAssignments
					Where PermissionSet.IsCustom = TRUE
					And PermissionSet.IsOwnedByProfile = FALSE)
				FROM User
				WHERE Id = : userId
				LIMIT 1];
	}
}