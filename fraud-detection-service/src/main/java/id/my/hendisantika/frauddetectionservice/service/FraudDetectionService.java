package id.my.hendisantika.frauddetectionservice.service;

import id.my.hendisantika.frauddetectionservice.entity.LoanStatus;
import id.my.hendisantika.frauddetectionservice.repository.FraudRecordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.28
 * To change this template use File | Settings | File Templates.
 */
@Service
@RequiredArgsConstructor
public class FraudDetectionService {

    private final FraudRecordRepository fraudRecordRepository;

    public LoanStatus checkForFraud(int customerId) {
        return fraudRecordRepository.existsByCustomerId(customerId) ? LoanStatus.REJECTED : LoanStatus.APPROVED;
    }
}
