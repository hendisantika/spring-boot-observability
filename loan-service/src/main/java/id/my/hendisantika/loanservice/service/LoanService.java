package id.my.hendisantika.loanservice.service;

import id.my.hendisantika.loanservice.client.FraudDetectionClient;
import id.my.hendisantika.loanservice.repository.LoanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * Project : spring-boot-observability
 * User: hendisantika
 * Email: hendisantika@gmail.com
 * Telegram : @hendisantika34
 * Date: 04/01/25
 * Time: 08.39
 * To change this template use File | Settings | File Templates.
 */
@Service
@RequiredArgsConstructor
public class LoanService {
    private final FraudDetectionClient fraudDetectionClient;
    private final LoanRepository loanRepository;

    public List<LoanDto> listAllLoans() {
        return loanRepository.findAll()
                .stream()
                .map(LoanDto::from)
                .toList();
    }

}
