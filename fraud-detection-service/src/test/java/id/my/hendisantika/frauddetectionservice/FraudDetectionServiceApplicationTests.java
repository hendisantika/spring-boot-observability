package id.my.hendisantika.frauddetectionservice;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.boot.test.context.SpringBootTest.WebEnvironment.RANDOM_PORT;

@Testcontainers
@SpringBootTest(
		properties = {
				"management.endpoint.health.show-details=always",
//				"spring.datasource.url=jdbc:tc:mysql:9.1.0:///fraud_detection?TC_INITSCRIPT=init.sql",
				"spring.datasource.url=jdbc:tc:mysql:9.2.0:///fraud_detection",
		},
		webEnvironment = RANDOM_PORT
)
class FraudDetectionServiceApplicationTests {

	@Container
	private static final MySQLContainer<?> mysqlContainer = new MySQLContainer<>("mysql:9.2.0")
			.withDatabaseName("fraud_detection")
			.withUsername("yu71")
			.withPassword("53cret");

	@Test
	void testMySQLContainerIsRunning() {
		assertThat(mysqlContainer.isRunning()).isTrue();
	}
}
